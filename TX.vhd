library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity TX is
	port(
	clk : in std_logic;
	reset : in std_logic;
	par_sel : in std_logic;
	baud_sel : in std_logic;
	data_bus : inout std_logic_vector(11 downto 0);
	tx_busy : out std_logic;
	TxD : out std_logic);
end TX;

architecture RTL of TX is 
  -- ADDR:
  -- 000 = TxConfig (NA - Parity - Baud)
  -- 001 = TxData (Data in)
  -- 010 = TxStatus (NA - Busy)
signal addr : std_logic_vector := data_bus(2 downto 0);
signal data : std_logic_vector := data_bus(10 downto 3);
signal tx_data : std_logic_vector(7 downto 0);

	begin 
 p_main: process(clk, reset) is 
          begin
            if reset = '1' then
              -- reset something
            elsif rising_edge(clk) then
                
            end if;
          end process p_main;

end architecture RTL;
--case addr
--when 000 => baud <= data_bus(2 downto 0); parity <= data_bus(4 downto 3);