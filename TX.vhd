library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.uart_library.all;

entity TX is
    port(
        clk : in std_logic;
        rst : in std_logic;
        Rd : in std_logic;
        Wr : in std_logic;
        addr : in std_logic_vector(ADDR_BITS_N - 1 downto 0);
        data_bus : inout std_logic_vector(DATA_BITS_N - 1 downto 0);
        TxD : out std_logic
    );
end TX;

architecture RTL of TX is 

    -- ADDR:
    -- 000 = TxConfig (NA - Parity - Baud)
    -- 001 = TxData (Data in)
    -- 010 = TxStatus (NA - Busy)

    type state_type is (IDLE, START, DATA, STOP);
    signal state : state_type := IDLE; -- Start in IDLE

    signal tx_data : std_logic_vector(DATA_BITS_N - 1 downto 0);  -- Assigned only in p_ctrl
    signal tx_data_internal : std_logic_vector(DATA_BITS_N - 1 downto 0);  -- Used in p_main
    signal bit_count : integer range 0 to 7 := 0;
    signal tx_done : std_logic;             
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

begin 
    -- Tri-state buffer for data_bus
    data_bus <= data_out when Rd = '1' else (others => 'Z');

    -- Process for Baud 
    p_baud : process(clk, rst)
    begin
        if rst = '0' then
            baud_counter <= 0;
            baud_tick <= '0';
        elsif rising_edge(clk) then
            if baud_counter = baud_divider - 1 then
                baud_tick <= '1'; 
                baud_counter <= 0;     
            else
                baud_tick <= '0';
                baud_counter <= baud_counter + 1;
            end if;
        end if;
    end process p_baud;

    -- Process to transmit data
    p_main: process(clk, rst)
    begin
        if rst = '0' then 
            state <= IDLE;
            TxD <= '1';  
            bit_count <= 0;
            tx_busy <= '0';
            tx_done <= '0';
        elsif rising_edge(clk) then 
            if baud_tick = '1' then
                case state is
                    when IDLE =>
                        tx_busy <= '0';
                        tx_done <= '0';
                        TxD <= '1';

                        if Wr = '1' and addr = TX_DATA_A then
                            tx_data_internal <= tx_data;  -- Load tx_data to internal signal for transmission
                            state <= START;
                        end if;

                    when START =>
                        tx_busy <= '1';  
                        bit_count <= 0;  
                        state <= DATA;

                    when DATA =>
                        if bit_count < 8 then
                            TxD <= tx_data_internal(bit_count);  -- Use tx_data_internal for transmission
                            bit_count <= bit_count + 1;
                        else
                            state <= STOP;  
                        end if;

                    when STOP =>
                        tx_done <= '1';  
                        TxD <= '1'; 
                        state <= IDLE;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process p_main;

    -- Process to control data_out and configuration settings
    p_ctrl: process(clk, rst)
    begin
        if rst = '0' then
            data_out <= (others => '0');
            baud_rate <= 115200; 
            parity <= (others => '0');
            tx_data <= (others => '0');  -- Reset tx_data here
            
        elsif rising_edge(clk) then
            -- Handle Read Operation
            if Rd = '1' then
                case addr is
                    when TX_STATUS_A =>
                        data_out <= "0000000" & tx_busy;  -- Output status
                    when TX_CONFIG_A =>
                        data_out <= (others => '0');      -- Default configuration read
                    when others =>
                        data_out <= (others => '0');      -- Default for undefined addresses
                end case;
            else
                data_out <= (others => 'Z'); -- High impedance when not reading
            end if;

            -- Handle Write Operation
            if Wr = '1' then
                case addr is
                    when TX_CONFIG_A =>
                        baud_rate <= to_integer(unsigned(data_bus(TX_BAUD_S downto TX_BAUD_E)));
                        parity <= data_bus(TX_PARITY_S downto TX_PARITY_E);
                        baud_divider <= CLOCK_FREQ_HZ / baud_rate;
                    when TX_DATA_A =>
                        tx_data <= data_bus;  -- Load data to be transmitted
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process p_ctrl;

end architecture RTL;

