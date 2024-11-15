library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_library.all;

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
	signal clk 	: std_logic := '0';
	signal rst 	: std_logic := '0';
	signal snd	: std_logic := '0';
	signal baud_sel	: std_logic_vector(2 downto 0) := "100";
	signal par_sel 	: std_logic_vector(1 downto 0) := "10";
	signal databus 	: std_logic_vector(7 downto 0) := (others => 'Z');
	signal addr 	: std_logic_vector(2 downto 0);
	signal snd_led 	: std_logic;
	signal wr 	: std_logic;
	signal rd 	: std_logic;
-- Clock period definition
	constant clk_period : time := 20 ns;
begin
	uut: CTRL
		port map(
			clk => clk,
			rst => rst,
			snd => snd,
			baud_sel => baud_sel,
			par_sel => par_sel,
			databus => databus,
			addr => addr,
			snd_led => snd_led,
			wr => wr,
			rd => rd
		);
		
		clk_process: process
		begin
			while true loop
				clk <= '0';
				wait for clk_period / 2;
				clk <= '1';
				wait for clk_period/2;
			end loop;
		end process;

		stim_proc: process

        -- Initialization procedure
        procedure tb_init is
        begin
            wr <= '0';
            rd <= '0';
            addr <= "000";
            baud_sel <= "100";
            par_sel <= "10";
            snd <= '1';
            snd_led <= '0';
            databus <= (others => 'Z');
            wait until rising_edge(clk);
        end tb_init;
		begin
			rst <= '0';
			wait for clk_period;
			rst <= '1';
			wait for clk_period;

----------------------- Sending first character
			-- wait for clk_period;
			-- snd <= '1';
			-- wait for clk_period/2;

			wait until (addr = "110");
			wait for clk_period;
			databus <= "00000000"; ---endret busy til 00...00

			wait until (addr = "101");
			wait for clk_period;
			databus <= "01000001"; -- ASCII character "A"

			wait until (addr = "010");
			wait for clk_period;
			databus <= "00000001";	

			wait for clk_period;
			--snd <= '0';

			wait for 10*clk_period;
			databus <= (others => 'Z');

----------------------- Sending second character
			

			wait for delay;
			databus <= "00000000";
			
			wait for delay;
			databus <= "01000100"; -- ASCII character "D"

			wait for delay;
			databus <= "00000001";

			wait for 10*clk_period;
			databus <= (others => 'Z');

----------------------- Sending third character
			wait for clk_period;
			snd <= '1';
			wait for clk_period/2;

			wait for delay;
			databus <= "00000000";
			
			wait for delay;
			databus <= "01000001"; -- ASCII character "A"

			wait for delay;
			databus <= "00000001";

			wait for 10*clk_period;
			databus <= (others => 'Z');
			wait for clk_period;
			--snd <= '0';

----------------------- Sending fourth character
			wait for clk_period;
			snd <= '1';
			wait for clk_period/2;

			wait for delay;
			databus <= "00000000";
			
			wait for delay;
			databus <= "01001101"; -- ASCII character "M"

			wait for delay;
			databus <= "00000001";

			wait for 10*clk_period;
			databus <= (others => 'Z');
			wait for clk_period;
			--snd <= '0';
			
            wait;
		end process;
end architecture SimulationModel;

