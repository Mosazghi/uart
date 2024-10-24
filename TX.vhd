library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity TX is
	port(
	clk : in std_logic;
	reset : in std_logic;
	data_bus : inout std_logic_vector(7 downto 0);
	Rd : in std_logic;
	Wr : in std_logic;
	addr : in std_logic_vector(2 downto 0);
	TxD : out std_logic
	);
end TX;

architecture RTL of TX is 
  -- ADDR:
  -- 000 = TxConfig (NA - Parity - Baud)
  -- 001 = TxData (Data in)
  -- 010 = TxStatus (NA - Busy)
  
	type state_type is (IDLE, LOAD, TRANSMIT, DONE);
	signal state : state_type := IDLE; -- Initialize state to IDLE
  
	signal tx_data : std_logic_vector(7 downto 0);
	signal bit_count : integer range 0 to 7 := 0;
	signal tx_busy : std_logic := '0';              -- Busy flag
   signal tx_done : std_logic := '0';              -- Done flag

	begin 


p_main: process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
            TxD <= '1';  -
            bit_count <= 0;
            tx_busy <= '0';
            tx_done <= '0';

        elsif rising_edge(clk) then
            case state is
                -- IDLE state: waiting for data to be written to the bus
                when IDLE =>
                    tx_busy <= '0';
                    tx_done <= '0';
                    TxD <= '1';  -- TxD idle
                    if Wr = '1' and addr = "000" then -- Check for write command to load data
                        tx_data <= data_bus;  -- Load data from bus into internal register
                        state <= LOAD;
                    end if;

                -- LOAD state: load data and prepare for transmission
                when LOAD =>
                    tx_busy <= '1';
                    bit_count <= 0;
                    state <= TRANSMIT;

                -- TRANSMIT state: send the data bit by bit
                when TRANSMIT =>
                    if bit_count < 8 then
                        TxD <= tx_data(bit_count); -- Send each bit of the data
                        bit_count <= bit_count + 1;
                    else
                        state <= DONE;
                    end if;

                -- DONE state: transmission is complete
                when DONE =>
                    tx_done <= '1';
                    TxD <= '1';  -- Send stop bit or return to idle state
                    state <= IDLE; -- Go back to IDLE after transmitting
            end case;
        end if;
          end process p_main;
			 
	 
end architecture RTL;