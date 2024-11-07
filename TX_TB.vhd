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
		
	 --Testbench Signals
    signal clk         : std_logic := '0';
    signal rst_n       : std_logic := '0';
    signal RxD         : std_logic := '1'; -- Idle state of UART line is '1'
    signal data_bus    : std_logic_vector(7 downto 0);
    signal addr        : std_logic_vector(2 downto 0);
    signal rd          : std_logic := '0';
    signal wr          : std_logic := '0';
  
    -- UART Parameters
    signal baud_rate_sel : std_logic_vector(2 downto 0) := "100"; -- Set default to 115200 baud
	 
	 -- Clock 
    constant CLK_PERIOD : time := 20 ns;
    constant BIT_PERIOD : time := 8681 ns; -- 115200 baud
	 
begin

  UUT: TX
  port map(
    clk => clk,
    rst => rst,
    Rd => Rd,
    Wr => Wr,
    addr => addr,
    data_bus => data_bus,
    TxD => TxD
  );

  data_bus <= data_bus_driver when Wr = '1' else (others => 'Z');
  
  --Clock generation
  p_clk: process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;
  
  --Stimulus process
  stimulus: process
	 begin
        rst <= '0';
        wait for CLK_PERIOD * 10;
        rst <= '1';
        wait for CLK_PERIOD * 10;

        wr <= '1';
        addr <= "100"; 
        data_bus <= "00000011"; 
        wait for CLK_PERIOD ;
        wr <= '0';
        addr <= "ZZZ";
        data_bus <= "ZZZZZZZZ";

        wait for CLK_PERIOD * 10;
 
  end process stimulus;

end architecture SimulationModel;
