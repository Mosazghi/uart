library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RX is 
  port ( clk : in  std_logic;
         rst_n : in  std_logic;
          RxD : in  std_logic;
          data_bus : inout  std_logic_vector(7 downto 0);
          addr : in  std_logic_vector(2 downto 0);
          rd : in  std_logic;
          wr : in  std_logic
        );
end RX;

architecture RTL of RX is
  type state_t is (IDLE, START, DATA, STOP);

 
  signal rx_data  : std_logic_vector(7 downto 0);   -- Data read from FIFO
  signal wrreq    : std_logic := '0';               -- Write request to FIFO
  signal rdreq    : std_logic := '0';               -- Read request from FIFO
  signal rx_ready : std_logic := '0';               -- RX ready flag (internal)
  signal rx_done  : std_logic := '0';               -- Indicates a byte has been received
  signal fifo_empty : std_logic;                    -- FIFO empty status
  signal fifo_full  : std_logic;                    -- FIFO full status

  signal state : state_t := IDLE;                   -- State machine state
begin
    -- FIFO Instance
    i_fifo : entity work.FIFO
        port map (
            clock => clk,
            data  => rx_data,           -- Data input to FIFO (received data)
            rdreq => rdreq,             -- Read request signal
            wrreq => wrreq,             -- Write request signal
            empty => fifo_empty,        -- FIFO empty status
            full  => fifo_full,         -- FIFO full status
            q     => rx_data            -- Data output from FIFO
        );

  -- Process to receive data 
  p_main: process(clk, rst_n) is 
          begin
            if rst_n = '0' then
              -- reset something
            elsif rising_edge(clk) then
              case state is
                when IDLE =>
                  if RxD = '0' then
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
              -- reset something
            elsif rising_edge(clk) then
            end if;
          end process p_ctrl;
end architecture RTL;
