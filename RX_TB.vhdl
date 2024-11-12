library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use work.uart_library.all;
entity RX_tb is
end RX_tb;

architecture behavior of RX_tb is
    -- Component Declaration for the RX module
    component RX
        generic (
            OVERSAMPLING_FACTOR : integer := 8
        );
        port(
            clk       : in  std_logic;
            rst_n     : in  std_logic;
            RxD       : in  std_logic;
            data_bus  : inout std_logic_vector(7 downto 0);
            addr      : in  std_logic_vector(2 downto 0);
            rd        : in  std_logic;
            wr        : in  std_logic
        );
    end component;

    -- Testbench Signals
    signal clk         : std_logic := '0';
    signal rst_n       : std_logic := '0';
    signal RxD         : std_logic := '1'; -- Idle state of UART line is '1'
    signal data_bus    : std_logic_vector(7 downto 0);
    signal addr        : std_logic_vector(2 downto 0);
    signal rd          : std_logic := '0';
    signal wr          : std_logic := '0';

    -- Clock generation: 50 MHz
    constant CLK_PERIOD : time := 20 ns;
    constant BIT_PERIOD : time := 8681 ns; -- 115200 baud

    -- UART parameters
    signal baud_rate_sel : std_logic_vector(2 downto 0) := "100"; -- Set default to 115200 baud

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: RX
        generic map (
            OVERSAMPLING_FACTOR => 8
        )
        port map (
            clk       => clk,
            rst_n     => rst_n,
            RxD       => RxD,
            data_bus  => data_bus,
            addr      => addr,
            rd        => rd,
            wr        => wr
        );

    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD/2;
        clk <= '1';
        wait for CLK_PERIOD/2;
    end process;

    -- Stimulus process
    stimulus_process : process
      -- Initialization procedure
      procedure tb_init is
      begin
        wr <= '0';
        rd <= '0';
        addr <= "000";
        data_bus <= (others => 'Z');
        RxD <= '1';
        -- wait until rst_n = '1';
        -- wait for 100 ns;
        wait until rising_edge(clk);
      end tb_init;

      -- reset 
      procedure tb_reset is
        begin
          rst_n <= '0';
          wait for CLK_PERIOD * 10;
          rst_n <= '1';
          wait for CLK_PERIOD * 10;
        end tb_reset;
           

    procedure configure_baud_rate is
    begin
      wr <= '1';
      addr <= RX_CONFIG_A; -- Set RX_CONFIG_A address
      data_bus <= "00000000";  -- Baud rate selection for 115200 baud
      wait for CLK_PERIOD;
      wr <= '0';
      addr <= "000";
      data_bus <= (others => 'Z');
      wait for CLK_PERIOD * 10;
    end configure_baud_rate;


    -- Procedure to send a byte through RxD
    procedure send_byte(data : std_logic_vector(7 downto 0)) is
    begin
      -- Start bit (0)
      RxD <= '0';
      wait for BIT_PERIOD;
      -- Data bits
      for i in 0 to 7 loop
        RxD <= data(i);
        wait for BIT_PERIOD;
      end loop;
      -- Stop bit (1)
      RxD <= '1';
    wait for BIT_PERIOD;
    end send_byte;


    -- Procedure to read data from RX
    procedure wait_for_not_full_and_send_data(data : std_logic_vector(7 downto 0)) is
    begin
      -- wait for BIT_PERIOD;
      rd <= '1';
      addr <= RX_STATUS_A; -- Set address for RX_DATA_A
      wait for CLK_PERIOD;
      rd <= '0';
      addr <= "000";
    if data_bus(1) = '0' then
    report "RX's FIFO is NOT full! -- GOOD" severity note;
        wait for CLK_PERIOD;
        send_byte(data);
    else
    report "RX's FIFO is full! -- BAD" severity note;
        end if;
   
    end wait_for_not_full_and_send_data;

    procedure read_rx_data is
        begin
          rd <= '1';
          addr <= RX_DATA_A; -- Set address for RX_DATA_A
          wait for CLK_PERIOD;
          rd <= '0';
          addr <= (others => '0');
        end read_rx_data;

    -- Procedure to check received data
    procedure check_received_data(expected_data : std_logic_vector(7 downto 0)) is
    begin
      assert data_bus = expected_data
        report "Mismatch in received data!" severity error;
        if data_bus = expected_data then
            report "Received data is correct!" severity note;
        else
            report "Received data is incorrect!" severity note;
        end if;
    end check_received_data;
     
    begin
      tb_init;
      -- tb_reset;
      rst_n <= '0';
      wait for CLK_PERIOD;
      rst_n <= '1';
      configure_baud_rate;

      wait_for_not_full_and_send_data("10101000"); -- H
      read_rx_data;
      check_received_data("10101000");

      wait for BIT_PERIOD;
      wait_for_not_full_and_send_data("01000101"); -- E
      read_rx_data;
      check_received_data("01000101");
      

      wait for BIT_PERIOD;
      wait_for_not_full_and_send_data("01001100"); -- L
      read_rx_data;
      check_received_data("01001100");

      wait for BIT_PERIOD;
      wait_for_not_full_and_send_data("01001100"); -- L
      read_rx_data;
      check_received_data("01001100");

      wait for BIT_PERIOD;
      wait_for_not_full_and_send_data("01001111"); -- O
      read_rx_data;
      check_received_data("01001111");

      wait for BIT_PERIOD;
      wait_for_not_full_and_send_data("01001000"); -- H
      read_rx_data;
      check_received_data("01001000");
      wait for 10000 ns;
      assert false report "Testbench finished" severity failure;
    end process;
end behavior;

