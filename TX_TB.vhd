library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_library.all;

entity TX_tb is
end TX_tb;

architecture SimulationModel of TX_tb is

  constant CLK_FREQ_HZ : integer := 50000000;  
  constant CLK_PER : time := 20 ns;
  constant delay : time := 100 ns;
  
  component TX
      port(
        clk : in std_logic;
        rst : in std_logic;
        Rd : in std_logic;
        Wr : in std_logic;
        addr : in std_logic_vector(ADDR_BITS_N - 1 downto 0);
        data_bus : inout std_logic_vector(DATA_BITS_N - 1 downto 0);
        TxD : out std_logic
    );
  end component TX;

  signal clk, rst, Rd, Wr : std_logic := '0';
  signal addr : std_logic_vector(ADDR_BITS_N - 1 downto 0) := (others => '0');
  signal data_bus : std_logic_vector(DATA_BITS_N - 1 downto 0);
  signal TxD : std_logic;
  signal baud_rate  : integer range 9600 to 115200 := 115200; -- Baud rate
  signal baud_divider : integer;
  
  signal data_bus_driver : std_logic_vector(DATA_BITS_N - 1 downto 0) := (others => '0');
  
  
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

  p_clk: process
  begin
    clk <= '0';
    wait for CLK_PER / 2;
    clk <= '1';
    wait for CLK_PER / 2;
  end process p_clk;
  
  stimulus: process
  begin
    rst <= '1';
    wait for delay;
    rst <= '0';
    wait for delay;
    
    data_bus_driver <= "00001010";
    addr <= "000";
    Wr <= '1';
    wait for CLK_PER;
    Wr <= '0';
    wait for delay;
    
    data_bus_driver <= "10101010";
    addr <= "001";
    Wr <= '1';
    wait for CLK_PER;
    Wr <= '0';
    wait for delay;
    
    addr <= "010";
    Rd <= '1';
    wait for CLK_PER;
    Rd <= '0';
    wait for delay;
    
    wait for 5000 ns;
    wait;
  end process stimulus;

end architecture SimulationModel;
