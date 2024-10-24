library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TX is
	port(
	clk : in std_logic;
	rst : in std_logic;
	Rd : in std_logic;
	Wr : in std_logic;
	addr : in std_logic_vector(2 downto 0);
	data_bus : inout std_logic_vector(7 downto 0);
	TxD : out std_logic
	);
end TX;

architecture RTL of TX is 

  -- ADDR:
  -- 000 = TxConfig (NA - Parity - Baud)
  -- 001 = TxData (Data in)
  -- 010 = TxStatus (NA - Busy)
  
  type state_type is (IDLE, LOAD, TRANSMIT, DONE);
  signal state : state_type := IDLE; -- Start in IDLE
  
  signal tx_data : std_logic_vector(7 downto 0);
  signal bit_count : integer range 0 to 7 := 0;
  signal tx_busy : std_logic := '0';              
  signal tx_done : std_logic := '0';             

  signal data_out : std_logic_vector(7 downto 0); --Temp data
begin 
-- Tristate 
  data_bus <= data_out when Rd = '1' else (others => 'Z');

p_main: process(clk, rst)
begin
    if rst = '0' then 
        state <= IDLE;
        TxD <= '1';  
        bit_count <= 0;
        tx_busy <= '0';
        tx_done <= '0';
        data_out <= (others => 'Z');

    elsif rising_edge(clk) then
        case state is
            when IDLE =>
                tx_busy <= '0';
                tx_done <= '0';
                TxD <= '1'; 

                if Wr = '1' and addr = "001" then
                    tx_data <= data_bus;  
                    state <= LOAD;

                elsif Rd = '1' then
                    if addr = "010" then 
                        data_out <= "000000" & tx_busy; 
                    elsif addr = "000" then
                        data_out <= (others => '0');  
                    end if;
                end if;

            when LOAD =>
                tx_busy <= '1';  
                bit_count <= 0;  
                state <= TRANSMIT;

            when TRANSMIT =>
                if bit_count < 8 then
                    TxD <= tx_data(bit_count);
                    bit_count <= bit_count + 1;
                else
                    state <= DONE;  
                end if;

            when DONE =>
                tx_done <= '1';  
                TxD <= '1'; 
                state <= IDLE; 
        end case;
    end if;
end process p_main;

end architecture RTL;
