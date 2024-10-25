library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.uart_library.all;

entity RX is 
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
  signal baud_rate  : std_logic_vector(RX_BAUD_S downto RX_BAUD_E); 
  signal parity     : std_logic_vector(RX_PARITY_S downto RX_PARITY_E); 
  
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
              q     => data_bus           -- Data output from FIFO
          );

    -- Process to receive data 
    p_main: process(clk, rst_n) is 
            begin
              if rst_n = '0' then
                -- NOTE: reset something 
              elsif rising_edge(clk) then
                case state is
                  when IDLE =>
                    if RxD = '0' then
                      rx_ready <= '1';
                      state <= START;
                    end if;
                  when START =>
                  when DATA =>
                  when STOP =>
                end case;
                            
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
                      baud_rate <= data_bus(RX_BAUD_S downto RX_BAUD_E);
                      parity <= data_bus(RX_PARITY_S downto RX_PARITY_E);
                    when others =>
                      null; -- FIXME: ignore for now 
                  end case;
                  end if;
              end if;
            end process p_ctrl;
  end architecture RTL;
