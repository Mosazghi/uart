library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_library.all;

entity RX is 
  generic (
            OVERSAMPLING_FACTOR : integer := 8
          );
    port( clk : in  std_logic;
          rst_n : in  std_logic;
          RxD : in  std_logic;
          data_bus : inout  std_logic_vector(DATA_BITS_N - 1 downto 0);
          addr : in  std_logic_vector(ADDR_BITS_N - 1 downto 0);
          rd : in  std_logic; -- Read signal from CTRL
          wr : in  std_logic -- Write signal from CTRL
        );
end RX;

architecture RTL of RX is
  type state_t is (IDLE, START, DATA, STOP);
  signal state : state_t := IDLE;                   -- State machine 
 
  signal rx_data_buf  : std_logic_vector(DATA_BITS_N - 1 downto 0);   -- Data buffer for received (RxD)
  signal wrreq    : std_logic := '0';               -- Write request to FIFO
  signal rdreq    : std_logic := '0';               -- Read request from 
  signal rx_ready : std_logic := '0';               -- RX ready flag (internal)
  signal rx_done  : std_logic := '0';               -- Indicates a byte has been received

  -- Status signals
  signal fifo_empty : std_logic := '0';                    -- FIFO empty status
  signal fifo_full  : std_logic := '0';                    -- FIFO full status
  signal parity_err : std_logic := '0';             -- Parity error flag
  signal data_lost  : std_logic := '0';             -- Data lost flag

  -- Configs signals 
  signal baud_rate  : integer range 9600 to 115200 := 115200; -- Baud rate
  signal parity     : std_logic_vector(RX_PARITY_S downto RX_PARITY_E); 
  
  signal baud_divider : integer := 0; 
  signal baud_tick : std_logic := '0'; 
  signal baud_counter : integer; 

  signal os_divider : integer := 0; 
  signal os_tick : std_logic := '0'; 
  signal os_counter : integer; 
  signal sample_buf : std_logic_vector(DATA_BITS_N - 1 downto 0);   -- Data buffer for sampling 

  function count_ones_middle_six(data : std_logic_vector) return integer is
  variable count : integer := 0;
  begin
    for i in 1 to 6 loop
      if data(i) = '1' then
      count := count + 1;
      end if;
    end loop;
    return count;
  end function;
begin
    -- FIFO Instance
    i_fifo : entity work.FIFO
        port map (
              clock => clk,
              data  => rx_data_buf,           -- Data input to FIFO (received data)
              rdreq => rdreq,             -- Read request signal to FIFO
              wrreq => wrreq,             -- Write request signal to FIFO
              empty => fifo_empty,        -- FIFO empty status
              full  => fifo_full,         -- FIFO full status
              q     => data_bus           -- Data output from FIFO  endre 
          );

    p_baud_generator : process(clk, rst_n)
        begin
            if rst_n = '0' then
                baud_counter <= 0;
                baud_tick <= '0';
            elsif rising_edge(clk) then
                if baud_counter = baud_divider - 1 then
                    baud_tick <= '1'; 
                    baud_counter <= 0;      
                else
                    baud_tick <= '0';
                    baud_counter <= baud_counter + 1;
                end if;
            end if;
        end process;

        p_os_generator : process(clk, rst_n)
        begin 
            if rst_n = '0' then
              os_counter <= 0;
              os_tick <= '0';
            elsif rising_edge(clk) then
              if os_counter = os_divider - 1 then
                os_tick <= '1';
                os_counter <= 0;
                sample_buf <= sample_buf & RxD;
              else
                os_tick <= '0';
                os_counter <= os_counter + 1;
                sample_buf <= (others => 'Z');
              end if;
            end if;
        end process;
            
            
    -- Process to receive data 
    p_main: process(clk, rst_n) is 
            variable v_majority_bit : std_logic := 'Z';
            variable v_bit_count : integer range 0 to 7 := 0;
            begin
              if rst_n = '0' then
                -- NOTE: reset something 
              elsif rising_edge(clk) then
                if baud_tick = '1' then
                  case state is
                    when IDLE => -- Wait for start bit (RxD = '0')
                      if RxD = '0' then
                        rx_done <= '0';
                        state <= START;
                      end if;
                    when START => -- sample start bit 
                      if os_tick = '1' then 
                        if count_ones_middle_six(sample_buf) < 3 then -- Start bit verified (# 1's < # 0's)
                          state <= DATA;
                          else  --false start bit 
                            state <= IDLE;
                        end if; 
                      end if; 
                    when DATA => -- sample data bits 
                      if os_tick = '1' then 
                        if count_ones_middle_six(sample_buf) > 3 then -- Data bit verified (# 1's > # 0's)
                          v_majority_bit := '1';
                          else  
                          v_majority_bit := '0';
                        end if;
                        rx_data_buf(v_bit_count) <= v_majority_bit;
                        wrreq <= '1';  
                        v_bit_count := v_bit_count + 1;
                      end if;

                      if v_bit_count = 7 then
                        state <= STOP;
                      end if;

                    when STOP => --sample stop bit 
                      if os_tick = '1' then 
                        if count_ones_middle_six(sample_buf) > 3 then -- Stop bit verified (# 1's > # 0's)
                          state <= IDLE;
                          else  --false stop bit 
                            state <= IDLE;
                        end if; 
                      end if; 
                  end case;
                end if; 
              end if;
            end process p_main;

    -- Process to/from CTRL 
    p_ctrl: process(clk, rst_n) is
            begin
              if rst_n = '0' then
                -- NOTE: reset something 
              elsif rising_edge(clk) then
                if rd = '1' then
                  case addr is
                    when RX_DATA_A =>
                      data_bus <= rx_data_buf;
                    when RX_STATUS_A =>
                      data_bus <= "0000" & parity_err & data_lost & fifo_full & fifo_empty;
                  end case;
                end if;

                if wr = '1' then
                  case addr is
                    when RX_CONFIG_A =>
                      baud_rate <= to_integer(unsigned(data_bus(RX_BAUD_S downto RX_BAUD_E)));
                      parity <= data_bus(RX_PARITY_S downto RX_PARITY_E);
                      baud_divider <= CLOCK_FREQ_HZ/baud_rate; 
                      os_divider <= baud_divider/OVERSAMPLING_FACTOR;
                    when others =>
                      null; -- FIXME: ignore for now 
                  end case;
                  end if;
              end if;
            end process p_ctrl;
  end architecture RTL;
