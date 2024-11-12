library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_library.all;

entity TX_tb is
end TX_tb;

architecture SimulationModel of TX_tb is
  
  component TX
      port(
        clk : in std_logic;
        rst : in std_logic;
        Rd : in std_logic;
        Wr : in std_logic;
        addr : in std_logic_vector(2 downto 0);
        data_bus : inout std_logic_vector(7 downto 0);
        TxD : out std_logic
    );
  end component TX;
		
    -- Testbench Signals
    signal clk         : std_logic := '0';
    signal rst         : std_logic := '0';
    signal TxD         : std_logic;
    signal data_bus    : std_logic_vector(7 downto 0);
    signal data_bus_driver : std_logic_vector(7 downto 0) := (others => '0');
    signal addr        : std_logic_vector(2 downto 0);
    signal rd          : std_logic := '0';
    signal wr          : std_logic := '0';

    -- UART Parameters
    constant CLK_PERIOD : time := 20 ns;
	 
begin

    UUT: TX
        port map(
            clk => clk,
            rst => rst,
            Rd => rd,
            Wr => wr,
            addr => addr,
            data_bus => data_bus,
            TxD => TxD
        );

    data_bus <= data_bus_driver when wr = '1' else (others => 'Z');
  
    -- Clock generation
    p_clk: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stimulus: process
    begin
        -- Apply Reset
        rst <= '0';
        wait for CLK_PERIOD * 10;
        rst <= '1';
        wait for CLK_PERIOD * 10;

        -- Set baud rate to 115200 
        wr <= '1';
        addr <= TX_CONFIG_A;        
        data_bus_driver <= "00000000"; 
        wait for CLK_PERIOD;
        wr <= '0';
        addr <= "ZZZ";
        data_bus_driver <= "ZZZZZZZZ";
		  
        -- Wait for configuration 
        wait for CLK_PERIOD * 10;

        -- Send data to TX
        wr <= '1';
        addr <= TX_DATA_A;          
        data_bus_driver <= "01010101"; -- Example data to send
        wait for CLK_PERIOD;
        wr <= '0';
        addr <= "ZZZ";
        data_bus_driver <= "ZZZZZZZZ";

        -- Wait for TX to complete
        wait for CLK_PERIOD * 100;

        assert false report "Testbench finished" severity failure;
    end process stimulus;

end architecture SimulationModel;
