library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TX is
	port(
	clk : in std_logic;
	reset : in std_logic;
	par_sel : in std_logic;
	baud_sel : in std_logic;
	data_bus : inout std_logic_vector(11 downto 0);
	tx_busy : out std_logic;
	TxD : out std_logic
	);
end TX;

architecture RTL of TX is 
  -- ADDR:
  -- 000 = TxConfig (NA - Parity - Baud)
  -- 001 = TxData (Data in)
  -- 010 = TxStatus (NA - Busy)
signal addr : std_logic_vector(2 downto 0);
signal data : std_logic_vector(7 downto 0);
signal tx_data : std_logic_vector(7 downto 0);
signal parity_bit : std_logic := '0';
signal baud_rate_counter : integer := 0; 
signal baud_tick : std_logic := '0';

	begin 
	
addr <= data_bus(2 downto 0);
data <= data_bus(10 downto 3);

 p_main: process(clk, reset) is 
          begin
            if reset = '1' then
					tx_busy <= '0';
					TxD <= '1'; -- Idle state
            elsif rising_edge(clk) then
            case baud_sel is
                when "000" => if baud_rate_counter = 5208 then -- 9600 baud rate
                                baud_rate_counter <= 0;
                                baud_tick <= '1';
                              else
                                baud_rate_counter <= baud_rate_counter + 1;
                                baud_tick <= '0';
                              end if;
                when "001" => if baud_rate_counter = 2604 then -- 19200 baud rate
                                baud_rate_counter <= 0;
                                baud_tick <= '1';
                              else
                                baud_rate_counter <= baud_rate_counter + 1;
                                baud_tick <= '0';
                              end if;
                when "010" => if baud_rate_counter = 1302 then -- 38400 baud rate
                                baud_rate_counter <= 0;
                                baud_tick <= '1';
                              else
                                baud_rate_counter <= baud_rate_counter + 1;
                                baud_tick <= '0';
                              end if;
                when "011" => if baud_rate_counter = 651 then -- 57600 baud rate
                                baud_rate_counter <= 0;
                                baud_tick <= '1';
                              else
                                baud_rate_counter <= baud_rate_counter + 1;
                                baud_tick <= '0';
                              end if;
                when "100" => if baud_rate_counter = 434 then -- 115200 baud rate
                                baud_rate_counter <= 0;
                                baud_tick <= '1';
                              else
                                baud_rate_counter <= baud_rate_counter + 1;
                                baud_tick <= '0';
                              end if;
                when others => baud_tick <= '0';
            end case
        end if;
    end process;
            end if;
          end process p_main;
			 
 par_sel: process(par_sel, data)
	begin
        case par_sel is
            when "00" => parity_bit <= '0'; -- No parity
            when "01" => parity_bit <= not xor_reduce(data); -- Even parity
            when "10" => parity_bit <= xor_reduce(data); -- Odd parity
            when others => parity_bit <= '0';
        end case;
    end process par_sel;
	 
end architecture RTL;
--case addr
--when 000 => baud <= data_bus(2 downto 0); parity <= data_bus(4 downto 3);