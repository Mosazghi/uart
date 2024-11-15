library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CTRL_tb is
end CTRL_tb;

architecture SimulationModel of CTRL_tb is
	constant delay : time := 30 ns;

	component CTRL
		port(
			clk 		: in 	std_logic;
			rst 		: in 	std_logic;
			snd		: in 	std_logic;
			baud_sel	: in 	std_logic_vector(2 downto 0);
			par_sel 	: in 	std_logic_vector(1 downto 0);
			databus 	: inout std_logic_vector(7 downto 0);
			addr 		: inout std_logic_vector(2 downto 0);
			snd_led 	: out 	std_logic;
			wr 		: out 	std_logic;
			rd 		: out 	std_logic

		);
	end component;

-- Signals to connect to UUT
	signal clk 			: std_logic := '0';
	signal rst 			: std_logic := '0';
	signal snd			: std_logic := '0';
	signal baud_sel	: std_logic_vector(2 downto 0) := "100";
	signal par_sel 	: std_logic_vector(1 downto 0) := "10";
	signal databus 	: std_logic_vector(7 downto 0) := (others => 'Z');
	signal addr 		: std_logic_vector(2 downto 0);
	signal snd_led 	: std_logic;
	signal wr 			: std_logic;
	signal rd 			: std_logic;
-- Clock period definition
	constant clk_period : time := 10 ns;
begin
	uut: CTRL
		port map(
			clk 		=> clk,
			rst 		=> rst,
			snd 		=> snd,
			baud_sel	=> baud_sel,
			par_sel 	=> par_sel,
			databus 	=> databus,
			addr 		=> addr,
			snd_led 	=> snd_led,
			wr 		=> wr,
			rd 		=> rd
		);
		
		clk_process: process
		begin
			while true loop
				clk <= '0';
				wait for clk_period/2;
				clk <= '1';
				wait for clk_period/2;
			end loop;
		end process;

		stim_proc: process
		begin
			rst <= '0';
			wait for delay;
			rst <= '1';
			wait for clk_period;

----------------------- Sending first character
			wait until (addr = "110"); -- Venter til idle 
			wait for clk_period;
			databus <= "11111101"; -- Simulerer RX er klar til å sende data

			wait until (addr = "101"); -- Venter til RX sender data
			wait for clk_period;
			databus <= "01000001"; -- RX sender ASCII karakteren "A"

			wait until (addr = "010"); -- Venter om TX er busy
			wait for clk_period;
			databus <= "00000001"; -- TX busy

			wait for 10*clk_period;
			databus <= (others => 'Z'); -- TX ikke lengre busy

			wait for 2*clk_period;
			snd <= '1';
			wait for clk_period/4;
			snd <= '0';
			wait for 2*clk_period;

----------------------- Sending Second character

			wait until (addr = "110"); -- Venter til idle 
			wait for clk_period;
			databus <= "11111101"; -- Simulerer RX er klar til å sende data

			wait until (addr = "101"); -- Venter til RX sender data
			wait for clk_period;
			databus <= "01000100"; -- RX sender ASCII karakteren "D"

			wait until (addr = "010"); -- Venter om TX er busy
			wait for clk_period;
			databus <= "00000001"; -- TX busy
			
			wait for 5*clk_period;
			snd <= '1';
			wait for clk_period/4;
			snd <= '0';
			wait for 10*clk_period;
			databus <= (others => 'Z'); -- TX ikke lengre busy
			
----------------------- Sending Third character

			wait until (addr = "110"); -- Venter til idle 
			wait for clk_period;
			databus <= "11111101"; -- Simulerer RX er klar til å sende data

			wait until (addr = "101"); -- Venter til RX sender data
			wait for clk_period;
			databus <= "01011010"; -- RX sender ASCII karakteren "Z"

			wait until (addr = "010"); -- Venter om TX er busy
			wait for clk_period;
			databus <= "00000001"; -- TX busy
			
			wait for 5*clk_period;
			snd <= '1';
			wait for clk_period/4;
			snd <= '0';
			wait for 10*clk_period;
			databus <= (others => 'Z'); -- TX ikke lengre busy
			wait;
		end process;
end architecture SimulationModel;