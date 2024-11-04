library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_library.all;


entity RX_tb is
end RX_tb;


architecture SimulationModel of RX_tb is
  constant CLK_FREQ_HZ : integer := 50_000_000;  
  constant CLK_PER : time := 20 ns;
  constant delay : time := 100 ns;
  
  component RX
      port(
        clk : in std_logic;
        rst_n : in std_logic;
        RxD : in std_logic;
        data_bus : inout std_logic_vector(DATA_BITS_N - 1 downto 0);
        addr : in std_logic_vector(ADDR_BITS_N - 1 downto 0);
        rd : in std_logic;
        wr : in std_logic
    );
  end component RX;

  signal clk, rst_n, RxD, rd, wr : std_logic := '0';
  signal addr : std_logic_vector(ADDR_BITS_N - 1 downto 0) := (others => '0');
  signal data_bus : std_logic_vector(DATA_BITS_N - 1 downto 0);
  signal baud_rate  : integer range 9600 to 115200 := 115200; -- Baud rate
  signal baud_divider : integer;
  
  signal data_bus_driver : std_logic_vector(DATA_BITS_N - 1 downto 0) := (others => '0');

  begin
    i_rx: RX
    port map (
      clk => clk,
      rst_n => rst_n,
      RxD => RxD,
      data_bus => data_bus,
      addr => addr,
      rd => rd,
      wr => wr
    );

    p_clk : process
      begin
        clk <= '0';
        wait for CLK_PER / 2;
        clk <= '1';
        wait for CLK_PER / 2;
      end process p_clk;

end architecture SimulationModel;
