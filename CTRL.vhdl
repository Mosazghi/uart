library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity CTRL is
port (
    clk        : in std_logic;                            -- Klokke signal
    rst        : in std_logic;                            -- Reset signal
    snd        : in std_logic;
    baud_sel   : in std_logic_vector(2 downto 0);
    par_sel    : in std_logic_vector(1 downto 0);
    data_bus 	: inout std_logic_vector(10 downto 0); -- rd + wr + addr + data 
    snd_led    : out std_logic;
	 tx_data    : out std_logic_vector(7 downto 0);
	 
	 /*
    tx_ready   : in std_logic;
    rx_data    : in std_logic_vector(7 downto 0);
    rx_ready   : in std_logic;
    */

end entity CTRL;


architecture RTL of CTRL is
	-- Signal
	signal adresse : data_bus(2 downto 0);
	signal data		: data_bus(10 downto 3);
begin
	
	
end architecture