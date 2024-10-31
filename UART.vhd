library ieee;
use ieee.std_logic_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use ieee.numeric_std.all;

entity CTRL is
port (
    clk        : in std_logic;                            -- Klokke signal
    rst        : in std_logic;                            -- Reset signal
    snd        : in std_logic;                            --knapp
    baud_sel   : in std_logic_vector(2 downto 0);         -- Baud rate
    par_sel    : in std_logic_vector(1 downto 0);         -- Paritet
    buss       : inout std_logic_vector(12 downto 0);     -- Adder + Data på bussen
    snd_led    : out std_logic;				  					-- LED for å indikere aktivitet
    tx_data    : out std_logic_vector(7 downto 0);
    tx_ready   : in std_logic;                            -- TX klar signal
    rx_data    : in std_logic_vector(7 downto 0);         -- Mottat data
    rx_ready   : in std_logic;                            -- RX klar signal
    rd         :out std_logic_vector                      -- Read signal
    wr         :out std_logic_vector			 				 -- Write signal
	 );
	 

end entity CTRL;


entity UART is
    port (
        clk      : in std_logic;                          -- Clock signal(50MHz)
        rst      : in std_logic;                          -- Reset signal (KEY0), active LOW
        snd      : in std_logic;                          -- Button to transmit a predefind character, activ LOW
        RxD      : in std_logic;                          -- UART received data (input)
        TxD      : out std_logic;                         -- UART transmit signal(output)
        snd_led  : out std_logic;                         -- LED indicating received/transmitted
        baud_sel : in std_logic_vector(2 downto 0);       -- Baud rate selection SW0, SW1 and  SW2
        par_sel  : in std_logic_vector(1 downto 0);       -- Parity selection SW3 and SW4
        data_bus  : inout std_logic_vector(7 downto 0)    -- Data bus (shared for Tx and Rx)
    );
end entity UART;

architecture Behavioral of UART is
    -- Signal to connect internal components
    signal tx_data_out  : std_logic_vector(7 downto 0);     -- Data to transmit
    signal rx_data_in   : std_logic_vector(7 downto 0);     -- Data received
    signal tx_ready   	: std_logic;                        -- TX ready signal
    signal rx_ready   	: std_logic;                        -- RX ready signal
    signal wr         	: std_logic;                        -- Write signal
    signal rd         	: std_logic;    							-- Read signal
	 signal adder      	: std_logic_vector(2 downto 0) 		-- Address for register selection
	 
begin
    -- CTRL module
    u_ctrl: entity work.CTRL
        port map (
            clk     	=> clk,
            rst      => rst,
            snd      => snd,
            baud_sel => baud_sel,
            par_sel  => par_sel,
            data_bus => data_bus,
            snd_led  => snd_led,
				tx_data  => tx_data_out,
            tx_ready => tx_ready,
            rx_data  => rx_data_in,
            rx_ready => rx_ready,
				adder		=> adder,
            wr       => wr,
            rd       => rd
				
        );

    -- TX module
    u_tx: entity work.TX
        port map (
            clk      => clk,
            rst      => rst,
            Rd       => rd,                             -- Read signal from CTRL
            Wr       => wr,                            -- Write signal from CTRL
            addr     => adder,            					 -- Address for TX registers
            data_bus => data_bus,                          -- Shared 8-bit data bus
            TxD      => TxD                             -- UART Transmit data output
        );

    -- RX module
    u_rx: entity work.RX
        port map (
            clk      => clk,
            rst_n    => rst,
            RxD      => RxD,                             -- Receive data input
            data_bus => data_bus,                          -- Shared data bus
            addr     => adder,         					-- Address bus
            rd       => rd,                             -- Read signal from CTRL
            wr       => wr                             -- Write signal from CTRL
        );
end Behavioral;

