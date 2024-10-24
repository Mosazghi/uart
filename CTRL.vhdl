library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CTRL is
port (
    clk        : in std_logic;                           -- Klokke signal
    rst        : in std_logic;                           -- Reset signal
    snd        : in std_logic;
	 rx_ready	: in std_logic;
	 tx_busy		: in std_logic;
    baud_sel   : in std_logic_vector(2 downto 0);
    par_sel    : in std_logic_vector(1 downto 0);
	 rx_data		: in std_logic_vector(7 downto 0);
    -- data_bus 	: inout std_logic_vector(10 downto 0); 	-- rd + wr + addr + data 
    snd_led    : out std_logic;
	 tx_data    : out std_logic_vector(7 downto 0));
	 
	 /*
    tx_ready   : in std_logic;
    rx_data    : in std_logic_vector(7 downto 0);
    rx_ready   : in std_logic;
    */

end entity CTRL;	


architecture RTL of CTRL is
	---------------------------------
	-- Type
	---------------------------------
	type state_type is (Idle, Get, Send);
	
	---------------------------------
	-- Signal
	---------------------------------
	signal adresse : data_bus(2 downto 0);
	signal data		: data_bus(10 downto 3);
	signal state 	: state_type;
	
begin
	process(clk, rst) is begin
		if (rst = '0') then 
			state <= Idle; 
			snd_led <= '0';
			rx_data <= (others <= '0');
			tx_data <= (others <= '0');
		
		elsif (rising_edge(clk)) then
			
			case state is 
			
				when Idle =>
					if (rx_ready = '1') then
					end if;
					
				when Get =>
					if (tx_busy = '0' and snd = '1') then
						tx_data <= std_logic_vector(unsigned(rx_data));
						state <= Send;
					end if;
					
				when Send =>
					
				when others => null;
			end case;
		end if;
	end process;
	
	
end architecture