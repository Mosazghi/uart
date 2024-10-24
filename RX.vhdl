library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RX is 
  port ( clk : in  std_logic;
         reset : in  std_logic;
          RxD : in  std_logic;
          data_bus : inout  std_logic_vector(10 downto 0);
          par_sel : in  std_logic;
          buad_sel : in  std_logic;
          fifo_full : out  std_logic;
          fifo_empty : out  std_logic;
          data_lost : out  std_logic;
          parity_err : out  std_logic;
			 rx_ready : out std_logic
        );
end RX;

architecture RTL of RX is
  -- ADDR:
  -- 100 = RxConfig (NA - Parity - Baud)
  -- 101 = RxData (Data out)
  -- 110 = RxStatus (Parity error - Data lost - FIFO full - FIFO empty)
  signal data_out : std_logic_vector :=  data_bus(10 downto 3);
  signal full_addr : std_logic_vector :=  data_bus(2 downto 0);
  signal 
  
  -- 
  signal rx_data  : std_logic_vector(7 downto 0);   -- Data read from FIFO
  signal wrreq    : std_logic := '0';               -- Write request to FIFO
  signal rdreq    : std_logic := '0';               -- Read request from FIFO
  signal rx_ready : std_logic := '0';               -- RX ready flag (internal)
  signal rx_done  : std_logic := '0';               -- Indicates a byte has been received
begin

    -- FIFO Instance
    i_fifo : entity work.FIFO
        port map (
            clock => clk,
            data  => data_out,          -- Data input to FIFO (received data)
            rdreq => rdreq,             -- Read request signal
            wrreq => wrreq,             -- Write request signal
            empty => fifo_empty,        -- FIFO empty status
            full  => fifo_full,         -- FIFO full status
            q     => rx_data            -- Data output from FIFO
        );
  p_main: process(clk, reset) is 
          begin
            if reset = '1' then
              -- reset something
            elsif rising_edge(clk) then
                
            end if;
          end process p_main;
end architecture RTL;
