library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity UART_tb is
end entity UART_tb;

architecture SimulationModel of UART_tb is
	
	constant CLK_PER : time := 20 ns;  -- 50 MHz clock
	
	    -- Signals to connect to the UART entity
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '1';
    signal snd      : std_logic := '1';
    signal RxD      : std_logic := '1';
    signal TxD      : std_logic;
    signal snd_led  : std_logic;
    signal baud_sel : std_logic_vector(2 downto 0) := "000"; -- Initial baud rate
    signal par_sel  : std_logic_vector(1 downto 0) := "00"; -- Initial parity setting
begin

    --  UART module
    uut: entity work.UART
        port map (
            clk      => clk,
            rst      => rst,
            snd      => snd,
            RxD      => RxD,
            TxD      => TxD,
            snd_led  => snd_led,
            baud_sel => baud_sel,
            par_sel  => par_sel
        );

