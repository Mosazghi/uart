library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity CTRL is
port (
    clk        : in std_logic;                            -- Klokke signal
    rst        : in std_logic;                            -- Reset signal
    snd        : in std_logic;
    baud_sel    : in std_logic_vector(2 downto 0);
    par_sel    : in std_logic_vector(1 downto 0);
    buss        : inout std_logic_vector(12 downto 0);
    snd_led    : out    std_logic;

    tx_data    : out    std_logic_vector(7 downto 0);
    tx_ready    : in std_logic;
    rx_data    : in std_logic_vector(7 downto 0);
    rx_ready    : in std_logic;

    rd :out std_logic_vector
    wr :out std_logic_vector

end entity CTRL;
