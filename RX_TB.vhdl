library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

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
    begin
        -- Reset the UUT
        rst_n <= '0';
        wait for CLK_PERIOD * 10;
        rst_n <= '1';
        wait for CLK_PERIOD * 10;

        -- Configure RX for 115200 baud by setting baud_rate in RX_CONFIG_A
        wr <= '1';
        addr <= "100"; -- Address for RX_CONFIG_A
        data_bus <= "00000011";  -- Set baud rate selection bits
        wait for CLK_PERIOD ;
        wr <= '0';
        addr <= "ZZZ";
        data_bus <= "ZZZZZZZZ";
        -- Simulate sending one UART frame (start, data, and stop bits)
        wait for CLK_PERIOD * 10;

        -- Start bit (0)
        RxD <= '0';
        wait for BIT_PERIOD;

        -- Data bits (example: 10101010)
        for i in 0 to 7 loop
            if (i mod 2 = 0) then
                RxD <= '1';
            else
                RxD <= '0';
            end if;
            wait for BIT_PERIOD;
        end loop;

        -- Stop bit (1)
        RxD <= '1';
        wait for BIT_PERIOD;

        -- Check if data has been received by reading RX_DATA_A
        rd <= '1';
        addr <= "101"; -- Address for RX_DATA_A
        wait for CLK_PERIOD;
        rd <= '0';
        addr <= "101"; -- Address for RX_DATA_A
    wait for CLK_PERIOD* 22;

        -- Reset the UUT
        rst_n <= '0';
        wait for CLK_PERIOD * 10;
        rst_n <= '1';
        wait for CLK_PERIOD * 10;

        -- Configure RX for 115200 baud by setting baud_rate in RX_CONFIG_A
        wr <= '1';
        addr <= "100"; -- Address for RX_CONFIG_A
        data_bus <= "00000011";  -- Set baud rate selection bits
        wait for CLK_PERIOD ;
        wr <= '0';
        addr <= "ZZZ";
        data_bus <= "ZZZZZZZZ";
        -- Simulate sending one UART frame (start, data, and stop bits)
        wait for CLK_PERIOD * 10;

        -- Start bit (0)
        RxD <= '0';
        wait for BIT_PERIOD;

        -- Data bits (example: 10101010)
        for i in 0 to 7 loop
            if (i mod 2 = 0) then
                RxD <= '1';
            else
                RxD <= '0';
            end if;
            wait for BIT_PERIOD;
        end loop;

        -- Stop bit (1)
        RxD <= '1';
        wait for BIT_PERIOD;

        -- Check if data has been received by reading RX_DATA_A
        rd <= '1';
        addr <= "101"; -- Address for RX_DATA_A
        wait for CLK_PERIOD;
        rd <= '0';
        addr <= "101"; -- Address for RX_DATA_A
        -- Simulation complete
        assert false report "Testbench finished" severity failure;
    end process;
end behavior;

