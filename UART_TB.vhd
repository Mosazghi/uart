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
    signal baud_sel : std_logic_vector(2 downto 0) := "000"; -- baud rate
    signal par_sel  : std_logic_vector(1 downto 0) := "00"; -- parity setting
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
		  
		      -- Clock 
    clk_process: process
   begin
    clk <= '0';
    wait for CLK_PER / 2;
    clk <= '1';
    wait for CLK_PER / 2;
    end process clk_process;
	 
	     -- Test process
    test_process: process
    begin
        -- Reset UART 
        rst <= '0';
        wait for CLK_PER * 10;
        rst <= '1';
        wait for CLK_PER * 10;

        -- Test transmission 
        snd <= '0';  
        wait for CLK_PER * 5;
        snd <= '1';  

        -- Wait for transmission to complete
        wait for CLK_PER * 100;

        -- Test reception
        RxD <= '0';  -- Start bit
        wait for CLK_PER * 10;
        for i in 0 to 7 loop
            RxD <= '1';  -- Transmit data bit 
            wait for CLK_PER * 10;
        end loop;
        RxD <= '1';  -- Stop bit
        wait for CLK_PER * 20;

        -- 
        wait for CLK_PER * 50;

        -- Change baud rate and parity 
        baud_sel <= "010";  -- Change to a different baud rate
        par_sel <= "01";    -- Change to even parity

        -- Test transmission again 
        snd <= '0';  
        wait for CLK_PER * 5;
        snd <= '1';  

        -- Wait for transmission to complete
        wait for CLK_PER * 100;

        -- End of test
        wait;
    end process test_process;

end architecture SimulationModel;

