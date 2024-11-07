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

    type state_type is (IDLE, START, DATA, STOP);
    signal state : state_type := IDLE;

    signal tx_data : std_logic_vector(DATA_BITS_N - 1 downto 0);   
    signal tx_data_buf : std_logic_vector(DATA_BITS_N - 1 downto 0) := (others => '0'); 
    signal bit_count : integer range 0 to 7 := 0;
    signal data_out : std_logic_vector(DATA_BITS_N - 1 downto 0) := (others => '0');
    signal tx_ready : std_logic := '0';
    signal tx_done : std_logic := '0';

    -- Status signals
    signal tx_busy : std_logic := '0'; 

    -- Config signals
    signal baud_rate  : std_logic_vector(2 downto 0);
    signal parity     : std_logic_vector(1 downto 0);

    signal baud_divider : integer := 0;
    signal baud_counter : integer := 0;           
    signal baud_tick : std_logic := '0';  

begin 
    -- Tri-state buffer for data bus
    data_bus <= data_out when Rd = '1' else (others => 'Z');

    -- Process for Baud
    p_baud : process(clk, rst)
    begin
        if rst = '0' then
            baud_counter <= 0;
            baud_tick <= '0';
        elsif rising_edge(clk) then
            if baud_counter = baud_divider - 1 and tx_busy = '1' then
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
            tx_data_buf <= (others => '0');
            state <= IDLE;
            TxD <= '1';  
            bit_count <= 0;
            tx_busy <= '0';
        elsif rising_edge(clk) then 
            if baud_tick = '1' then
                case state is
                    when IDLE =>
                        tx_busy <= '0';
                        TxD <= '1';
                        if Wr = '1' and addr = TX_DATA_A then
                            tx_data_buf <= tx_data; 
                            tx_busy <= '1';         
                            state <= START;         
                        end if;

                    when START =>
                        tx_busy <= '1';  
                        TxD <= '0';       -- Drive the start bit
                        bit_count <= 0;  
                        state <= DATA;

                    when DATA =>
                        if bit_count < 8 then
                            TxD <= tx_data_buf(bit_count); 
                            bit_count <= bit_count + 1;
                        else
                            state <= STOP;  
                        end if;

                    when STOP =>
                        TxD <= '1';       -- Stop bit
                        tx_busy <= '0';   -- Clear busy status
                        state <= IDLE;

                    when others =>
                        state <= IDLE;
                end case;
            end if;
        end if;
    end process p_main;

-- Process to/from CTRL
p_ctrl: process(clk, rst)
begin
    if rst = '0' then
        
    elsif rising_edge(clk) then

        -- Read
        if Rd = '1' then
            case addr is
                when TX_STATUS_A =>
                    data_out <= "0000000" & tx_busy; 
                when TX_CONFIG_A =>
                    data_out <= (others => '0');      
                when others =>
                    data_out <= (others => '0');     
            end case;
        else
            data_out <= (others => 'Z');  
        end if;

        -- Write
        if Wr = '1' then
            case addr is
                when TX_CONFIG_A =>
                    baud_rate <= data_bus(TX_BAUD_S downto TX_BAUD_E);
                    parity <= data_bus(TX_PARITY_S downto TX_PARITY_E);
						  baud_divider <= baud_dividers(to_integer(unsigned(baud_rate)));

                when TX_DATA_A =>
                    tx_data <= data_bus; 

                when others =>
                    null; 
            end case;


        end if;
    end if;
end process p_ctrl;

end architecture RTL;


