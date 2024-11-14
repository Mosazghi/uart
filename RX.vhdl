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
  -- Precomputed oversampling dividers (os_divider values) for 8x oversampling
  constant OS_DIV_9600     : integer := 651;  -- 9600 baud with 8x oversampling
  constant OS_DIV_19200    : integer := 325;  -- 19200 baud with 8x oversampling
  constant OS_DIV_38400    : integer := 163;  -- 38400 baud with 8x oversampling
  constant OS_DIV_57600    : integer := 108;  -- 57600 baud with 8x oversampling
  constant OS_DIV_115200   : integer := 54;  -- 115200 baud with 8x oversampling

  -- Array for oversampling dividers (local to RX module)
  type os_div_array is array (0 to 4) of integer;
  constant os_dividers : os_div_array := (
    OS_DIV_115200,  
    OS_DIV_57600,  
    OS_DIV_38400,   
    OS_DIV_19200,  
    OS_DIV_9600   
  );

  type state_t is (IDLE, START, DATA, STOP);
  signal state : state_t := IDLE;                   -- State machine 
 
  signal in_fifo_buf  : std_logic_vector(DATA_BITS_N - 1 downto 0);   -- Data buffer for received (RxD)
  signal out_fifo_buf  : std_logic_vector(DATA_BITS_N - 1 downto 0);   -- Data buffer for received (RxD)
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
  signal baud_rate  : std_logic_vector(2 downto 0);
  signal parity     : std_logic_vector(1 downto 0);
  
  signal baud_divider : integer := 0; 
  signal baud_tick : std_logic := '0'; 
  signal baud_counter : integer := 0; 
  signal init_sig : std_logic := '0';


  signal os_divider : integer := 0; 
  signal os_tick : std_logic := '0'; 
  signal os_counter : integer; 
  signal os_tick_counter : integer := 0; 
  signal sample_buf : std_logic_vector(DATA_BITS_N - 1 downto 0);   -- Data buffer for sampling 
  signal rx_start : std_logic := '0'; 

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
             data  => in_fifo_buf,           -- Data input to FIFO (received data)
             rdreq => rdreq,             -- Read request signal to FIFO
             wrreq => wrreq,             -- Write request signal to FIFO
             empty => fifo_empty,        -- FIFO empty status
             full  => fifo_full,         -- FIFO full status
             q     => out_fifo_buf           -- Data output from FIFO  endre 
         );

    p_baud_generator : process(clk, rst_n)
        begin
            if rst_n = '0' then
                baud_counter <= 0;
                baud_tick <= '0';
            elsif rising_edge(clk) and rx_start = '1' then
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
              os_tick_counter <= 0;
              os_tick <= '0';
              sample_buf <= (others => '0'); 
            elsif rising_edge(clk) and rx_start = '1' then
              if os_counter = os_divider - 1 then
                if os_tick_counter = OVERSAMPLING_FACTOR - 1 then
                  os_tick <= '1';
                  os_tick_counter <= 0;
                else
                  os_tick_counter <= os_tick_counter + 1;
                end if;
                os_counter <= 0;
                sample_buf <=  RxD & sample_buf(DATA_BITS_N - 1 downto 1); 
              else
                os_tick <= '0';
                os_counter <= os_counter + 1;
              end if;
            end if;
        end process;
            
            
    -- Process to receive data 
    p_main: process(clk, rst_n) is 
            variable v_majority_bit : std_logic;
            variable v_bit_count : integer;
            variable v_rx_data_buf : std_logic_vector(DATA_BITS_N - 1 downto 0);
                       
            begin
              if rst_n = '0' then
                v_bit_count := 0;
                v_majority_bit := '0';
                v_rx_data_buf := (others => '0');
                state <= IDLE; 
                rx_ready <= '0';
                rx_done <= '0';
                parity_err <= '0';
                data_lost <= '0';
                rx_start <= '0';
                wrreq <= '0'; 
              elsif rising_edge(clk) then
                  case state is
                    when IDLE => 
                        wrreq <= '0';  
                        rdreq <= '0'; 
                        rx_ready <= '0';
                        rx_done <= '0';
                        if RxD = '0' then
                            rx_start <= '1';
                            state <= START;
                        end if;
                    when START => -- sample start bit 
                      if os_tick = '1' then 
                        if count_ones_middle_six(sample_buf) < 3 then -- Start bit verified (# 1's < # 0's)
                          --report "START BIT VERIFIED";
                          state <= DATA;
                          else  --false start bit 
                            state <= IDLE;
                        end if; 
                      end if; 
                                          
                    when DATA => -- sample data bits 
                        if os_tick = '1' then 
                          if count_ones_middle_six(sample_buf) > 3 then 
                            v_majority_bit := '1';
                            else  
                            v_majority_bit := '0';
                          end if;
                          v_rx_data_buf(v_bit_count) := v_majority_bit;

                          v_bit_count := v_bit_count + 1;
                          
                          if v_bit_count = 8 then
                            if fifo_full = '0' then
                              --report "BYTE RECEIVED";
                              wrreq <= '1';  
                              in_fifo_buf <= v_rx_data_buf;
                            rdreq <= '1'; 
                            end if; 
                            v_bit_count := 0;
                            v_majority_bit := '0';
                            v_rx_data_buf := (others => '0');
                            state <= STOP;
                          end if;
                        end if;

                    when STOP => --sample stop bit 
                        if os_tick = '1' then 
                          if count_ones_middle_six(sample_buf) > 3 then -- Stop bit verified (# 1's > # 0's)
                            --report "STOP BIT VERIFIED";
                            rx_ready <= '1';
                            else  --false stop bit 
                              null; --FIXME: handle false stop bit 
                          end if; 
                          state <= IDLE;
                          rx_done <= '1';
                          rx_start <= '0';
                        end if; 
                  end case;
              end if;
            end process p_main;

    -- Process to/from CTRL 
    p_ctrl: process(clk, rst_n) is
            begin
              if rst_n = '0' then
                data_bus <= (others => 'Z'); 
                baud_rate <= (others => '0'); 
                parity <= (others => '0'); 
                baud_divider <= DIV_115200;
                os_divider <= OS_DIV_115200;
              elsif rising_edge(clk) then
                data_bus <= (others => 'Z');
                if rd = '1' then
                  case addr is
                    when RX_DATA_A =>
                      report "READ DATA";
                      if fifo_empty = '0' then --NOTE: Necessary to check rx_ready as well? Don't think so.
                        data_bus <= out_fifo_buf;
                      end if;
                      
                    when RX_STATUS_A =>
                      report "STATUS";
                      data_bus <= "0000" & parity_err & data_lost & fifo_full & fifo_empty;
                    when others =>
                      null;
                  end case;
                end if;

                if wr = '1' then
                  case addr is
                    when RX_CONFIG_A =>
                      report "CONFIG";
                      baud_rate <= data_bus(RX_BAUD_S downto RX_BAUD_E);
                      parity <= data_bus(RX_PARITY_S downto RX_PARITY_E);
                      baud_divider <= baud_dividers(to_integer(unsigned(baud_rate)));
                      os_divider <= os_dividers(to_integer(unsigned(baud_rate)));
                    when others =>
                      null;
                  end case;
                  end if;
              end if;
            end process p_ctrl;
  end architecture RTL;
