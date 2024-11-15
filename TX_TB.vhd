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

    constant CLK_PERIOD : time := 20 ns;
    constant BIT_PERIOD : time := 8681 ns; -- 115200 baud
	 
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
  
    -- Clock generation
    p_clk : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Data bus handling to avoid conflicts
    data_bus <= data_bus_driver when wr = '1' or rd = '1' else (others => 'Z');

    -- Stimulus process
stimulus : process
   procedure tb_init is
   begin
       rst <= '1';
       wr <= '0';
       rd <= '0';
       addr <= "000";
       data_bus <= (others => 'Z');
       TxD <= '1';
       wait until rising_edge(clk);
   end tb_init;
	
   -- Reset procedure
   procedure tb_reset is
   begin
       rst <= '0';
       wait for CLK_PERIOD * 5;  
       rst <= '1';
       wait for CLK_PERIOD * 5;
   end tb_reset;
		
    -- Procedure to send a byte
    procedure send_byte_via_tx(data : std_logic_vector(7 downto 0)) is
    begin
        data_bus_driver <= data;       
        addr <= TX_DATA_A;             
        wr <= '1';                     
        wait for CLK_PERIOD;         
        wr <= '0';
        data_bus_driver <= (others => 'Z'); 
    end send_byte_via_tx;

    -- Procedure for verification of TxD 
    procedure verify_txd(data : std_logic_vector(7 downto 0)) is
    begin
        wait until TxD = '0'; 
        wait for BIT_PERIOD / 2;

        assert TxD = '0' report "Start bit mismatch" severity error;
        wait for BIT_PERIOD;

        assert TxD = data(0) report "Mismatch at bit 0" severity error;
        wait for BIT_PERIOD;

        assert TxD = '1' report "Stop bit mismatch" severity error;
    end verify_txd;

    begin
        tb_init;
        tb_reset; 

        send_byte_via_tx("10101000"); 
        minimal_verify_txd("10101000");

        wait for 5000 ns;  
        assert false report "Testbench finished" severity failure;
    end process;

end architecture SimulationModel;


