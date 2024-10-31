---------------------------------------------------------------------------------
-- Testbench of safe
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_library.all;


-- Entity of testbench (empty)
entity TX_tb is
end TX_tb;


architecture SimulationModel of TX_tb is

  ----------------------------------------------------------------------------- 
  -- Constant declarations
  ----------------------------------------------------------------------------- 
  constant CLK_FREQ_HZ : integer := 50000000;  
  constant CLK_PER : time := 20 ns;
  constant delay : time := 100 ns;

  -- Calculate the baud divider
  constant baud_divider : integer := CLK_FREQ_HZ / BAUD_RATE;
  
  -----------------------------------------------------------------------------
  -- Component declarasion
  -----------------------------------------------------------------------------
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
	 
  -----------------------------------------------------------------------------
  -- Signal declaration
  -----------------------------------------------------------------------------
	 
    type state_type is (IDLE, START, DATA, STOP);
	 
    signal state : state_type := IDLE; -- Start in IDLE

    signal tx_data : std_logic_vector(DATA_BITS_N - 1 downto 0);
    signal bit_count : integer range 0 to 7 := 0;
    signal tx_done : std_logic := '0';             
    signal data_out : std_logic_vector(DATA_BITS_N - 1 downto 0); -- Temp data

    -- Status signals
    signal tx_busy : std_logic := '0'; 

    -- Config signals
    signal baud_rate  : integer range 9600 to 115200 := 115200; -- Baud rate
    signal parity     : std_logic_vector(TX_PARITY_S downto TX_PARITY_E); 
	 
	 -- Baud configs
	 signal baud_divider : integer;
	 signal baud_counter : integer := 0;           
    signal baud_tick : std_logic := '0';
	 
  -- Internal testbench signals
  signal data_bus_driver : std_logic_vector(7 downto 0) := (others => '0');  -- Driver for data_bus
	 
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

  -- Tri-state buffer to drive the data_bus only during write operations
  data_bus <= data_bus_driver when Wr = '1' else (others => 'Z');
  
  ----------------------------------------------------------------------------- 
  -- Clock Generation Process
  ----------------------------------------------------------------------------- 
  p_clk: process
  begin
    clk <= '0';
    wait for CLK_PER / 2;
    clk <= '1';
    wait for CLK_PER / 2;
  end process p_clk;
  
  ----------------------------------------------------------------------------- 
  -- Test Sequence Process
  -----------------------------------------------------------------------------
	stimulus: process
	begin
		
		rst <= '1';
		wait for delay;
		rst <= '0';
		wait for delay;
		
		-- Write config (TxConfig)
		data_bus_driver <= "00001010"; --Example
		addr <= "000"; -- TxConfig address
		Wr <= '1';
		wait for CLK_PER;
		Wr <= '0';
		wait for delay;
		
		--Write Data to Transmit (TxData)
		data_bus_driver <= "10101010"; -- Example
		addr <= "001"; --TxData address
		Wr <= '1';
		wait for CLK_PER;
		Wr <= '0';
		wait for delay;
		
		-- Read Status (TxStatus)
		addr <= "010";
		Rd <= '1';
		wait for CLK_PER;
		Rd <= '0';
		wait for delay;
		
		wait for 5000 ns;
		
		wait;
		
		end process stimulus;
		
		end architecture SimulationModel;