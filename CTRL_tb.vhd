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
	
	

-- Signals to connect to UUT
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal snd      : std_logic := '0';
    signal baud_sel : std_logic_vector(2 downto 0) := (others => '0');
    signal par_sel  : std_logic_vector(1 downto 0) := (others => '0');
    signal databus  : std_logic_vector(7 downto 0) := (others => 'Z');
    signal snd_led  : std_logic;
    signal wr       : std_logic;
    signal rd       : std_logic;

    -- Clock period definition
    constant clk_period : time := 10 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    uut: ProjectUART
        port map (
            clk      => clk,
            rst      => rst,
            snd      => snd,
            baud_sel => baud_sel,
            par_sel  => par_sel,
            databus  => databus,
            snd_led  => snd_led,
            wr       => wr,
            rd       => rd
				State    => State,
				addr     => addr,
        );

    -- Clock process definitions
    clk_process :process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

	    startup_process: process
    begin
        -- Initialize
        databus <= (others => 'Z');   -- Release bus
        wr <= '0';
        
        wait for clk_period * 2;      -- Allow some initial time
        
        -- Test case for the 'start' state
        assert (State = "start") report "State is not start at beginning" severity error;
        
        wait for clk_period * 2;
        
        -- Test case for 'Write_Tx_Config'
        wait until rising_edge(clk);
        assert (State = "Write_Tx_Config") report "State did not transition to Write_Tx_Config" severity error;
        assert (addr = "100") report "Address not set correctly in start state" severity error;
        assert (databus(2 downto 0) = baud_sel) report "Baud select bits not set correctly in Rx configuration" severity error;
        
        wait for clk_period * 2;

        -- Test case for 'Finish'
        wait until rising_edge(clk);
        assert (State = "Finish") report "State did not transition to Finish" severity error;
        assert (wr = '0') report "WR should be 0 in Finish state" severity error;
        assert (databus = (others => 'Z')) report "Databus not set to high impedance in Finish state" severity error;
        
        -- Final check, state transitions to Idle
        wait until rising_edge(clk);
        assert (State = "Idle") report "State did not transition to Idle" severity error;

        -- Simulation end
        report "startup completed successfully" severity note;
        wait;
    end process;
	 
    -- Stimulus process
    stim_proc: process
    begin
        -- hold reset state for 100 ns.
        rst <= '1';
        wait for 100 ns;
        rst <= '0';

		      wait;
    end process;
		  
		  
		   send_process: process
        variable counter : integer := 0;
    begin
        -- Initialize
        snd <= '0';
        databus <= (others => 'Z');    -- Release bus
        wait for clk_period * 2;

        -- Drive UUT to Send state
        state <= Send;
        addr <= "010";                 -- Expecting address to check if Tx is ready
        RoW <= '0';                    -- Setting read mode

        -- Test if Tx is ready: databus(0) = '1' to simulate ready state
        databus <= "00000001";
        wait for clk_period;

        -- Test LED Blink Logic
        assert (led_state = '1') report "LED should be on initially" severity error;
        for i in 1 to timer_period * 2 loop
            wait until rising_edge(clk);
            if counter < timer_period then
                counter := counter + 1;
            else
                counter := 0;
                assert (led_state = not led_state) report "LED did not toggle after timer period" severity error;
            end if;
        end loop;

        -- Test single send trigger
        snd <= '1';
        wait until rising_edge(clk);
        assert (snd_led = led_state) report "snd_led did not match led_state after counter reset" severity error;
        
        -- Simulate Tx Ready to Send
        databus <= "00000000";          -- Tx ready signal
        snd <= '0';                     -- Button released
        wait until rising_edge(clk);

        -- Verify state transition to Idle and bus reset
        wait until rising_edge(clk);
        assert (state = Idle) report "State did not transition to Idle" severity error;
        assert (addr = "001") report "Address was not set correctly for Tx data send" severity error;
        assert (RoW = '1') report "RoW was not set to write for Tx data send" severity error;
        assert (databus = (others => 'Z')) report "Databus was not reset to high impedance after sending" severity error;

        -- Simulation End
        report "Send test completed successfully" severity note;
        wait;
    end process;
		
		  

        -- Add more stimulus as needed

    

end architecture;








