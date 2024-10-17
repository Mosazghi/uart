library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity TX is
	port(
	clk : in std_logic;
	reset : in std_logic;
	par_sel : in std_logic;
	baud_sel : in std_logic;
	tx_busy : out std_logic;
	tx_data : out std_logic);
end TX;

--case addr
--when 000 => baud <= data_bus(2 downto 0); parity <= data_bus(4 downto 3);