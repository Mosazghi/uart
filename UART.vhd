library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity CTRL is
port (
    clk        : in std_logic;                            -- Klokke signal
    rst        : in std_logic;                            -- Reset signal
    snd        : in std_logic;                            --knapp
    baud_sel   : in std_logic_vector(2 downto 0);         -- Baud rate
    par_sel    : in std_logic_vector(1 downto 0);         -- Paritet
    buss       : inout std_logic_vector(12 downto 0);     -- Adder + Data på bussen
    snd_led    : out std_logic;				  -- LED for å indikere aktivitet
    tx_data    : out std_logic_vector(7 downto 0);
    tx_ready   : in std_logic;                            -- TX klar signal
    rx_data    : in std_logic_vector(7 downto 0);         -- Mottat data
    rx_ready   : in std_logic;                            -- RX klar signal
    rd         :out std_logic_vector                      -- Read signal
    wr         :out std_logic_vector			  -- Write signal
	 ) --test 

end entity CTRL;
