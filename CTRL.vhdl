library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;

entity CTRL is
port (
    clk        : in std_logic;                            -- Klokke signal
    rst        : in std_logic;                            -- Reset signal
    snd        : in std_logic; 									 -- knapp
    baud_sel    : in std_logic_vector(2 downto 0);
    par_sel    : in std_logic_vector(1 downto 0);
	 
    data_bus : inout std_logic_vector(13 downto 0); -- rd + wr + addr + data 
	 
    snd_led    : out    std_logic;
	 
	 tx_data    : out    std_logic_vector(7 downto 0); -- bruker vi "data_bus" sletter vi disse
	 rx_data    : in std_logic_vector(7 downto 0);
	 
    tx_ready    : in std_logic;
    rx_ready    : in std_logic;

    rd :out std_logic_vector
    wr :out std_logic_vector

end entity CTRL;

architechture Behavioral

    signal snd : std_logic;
    signal tx_data     : std_logic_vector(7 downto 0);
    signal rx_data     : std_logic_vector(7 downto 0); -- tx rx data skal på bussen
    signal tx_ready    : std_logic;
    signal rx_ready    : std_logic;
	 
	 
    signal snd_led    : std_logic;
    signal baud_sel : std_logic_vector(2 downto 0);
    signal par_sel : std_logic_vector(1 downto 0);
	 signal par_err :std_logic_vector;
	  
	 
	 --FI FO FI FUM
	 
    signal fifo_full   : std_logic;
    signal fifo_empty  : std_logic;
	 signal data_lost  : std_logic;
	 signal par_err :std_logic
	 
	 --FI FO FI FUM
	 
	 signal rd :out std_logic_vector;
	 signal wr :out std_logic_vector;
	 
	 
begin

 u_ctrl : CTRL
    port map (
        clk         => clk,
        rst         => rst,
        push_button => push_button,
        tx_data     => tx_data,               -- Data to be transmitted (loopback)
        rx_data     => rx_data,               -- Data received
        tx_ready    => tx_ready,              -- CTRL indicates when ready for TX
        rx_ready    => rx_ready,              -- Data ready signal from RX module
        led_ctrl    => led_ctrl,              -- Control LED for data reception
        baud_sel => baud_sel,           -- Baud rate control signal
        par_sel => par_sel        -- Parity control signal
    );