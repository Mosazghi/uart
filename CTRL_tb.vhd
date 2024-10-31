library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_library.all;

entity CTRL_tb is
end CTRL_tb;

architecture SimulationModel of CTRL_tb is 
	constant CLK_FREQ_HZ : integer := 50000000;  
	constant CLK_PER : time := 20 ns;
	constant delay : time := 100 ns;
	
	component CTRL port(
		clk 		: in 		std_logic;
		rst		: in 		std_logic; 
		snd		: in 		std_logic;
		baud_sel	: in 		std_logic_vector(2 downto 0);
		par_sel	: in 		std_logic_vector(1 downto 0);
		databus	: inout 	std_logic_vector(7 downto 0);
		snd_led	: out 	std_logic;
		wr 		: out 	std_logic;
		rd 		: out 	std_logic;
		addr 		: inout		std_logic_vector(2 downto 0)
		);
	end component CTRL;
	
	signal clk 	: std_logic := '0';
	signal rst 	: std_logic := '0';
	signal rd	: std_logic := '0';
	signal wr 	: std_logic := '0';
	
	signal addr 		: std_logic_vector(2 downto 0) := (others => '0');
	signal data_bus 	: std_logic_vector(7 downto 0) := (others => 'Z');
	
begin
	p_clk: process
  begin
    clk <= '0';
    wait for CLK_PER / 2;
    clk <= '1';
    wait for CLK_PER / 2;
  end process p_clk;
	
end architecture;