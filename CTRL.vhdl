library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CTRL is port(
	clk 		: in 		std_logic;
	rst		: in 		std_logic; 
	snd		: in 		std_logic;
	baud_sel	: in 		std_logic_vector(2 downto 0);
	par_sel	: in 		std_logic_vector(1 downto 0);
	databus	: inout 	std_logic_vector(7 downto 0);
	snd_led	: out 	std_logic);
end entity CTRL;

architecture RTL of CTRL is
	type	 State_Type is (Idle, Get, Send);
	signal State : State_Type;

	signal RxData 	: std_logic_vector(7 downto 0);
	signal TxData 	: std_logic_vector(7 downto 0);
	signal adr		: std_logic_vector(2 downto 0);
	
	
	
begin
	
	process (clk, rst) is
		if (rst = '0') then 
			State <= Idle;
			snd_led <= '1';
			
			adr <= "100";	-- Setter adresse til Rx config
			RxData(2 downto 0) <= baud_sel;
			RxData(4 downto 3) <= par_sel;
			databus <= RxData;	-- Sender baud og parity over databussen
			
			adr <= "000";	-- Setter adresse til Tx config 
			TxData(2 downto 0) <= baud_sel;
			TxData(4 downto 3) <= par_sel;
			databus <= TxData;	-- Sender baud og parity over databussen
			
			-- Tilbakestiller databussen og 
			databus <= (others <= '0');
			RxData, TxData <= databus;
			
		elsif (rising_edge(clk)) then
			case State is
				when Idle =>	
					-- Sjekker Rx status
					if 	databus(3 downto 3) = '1' then
						-- Parity Error
					elsif databus(2 downto 2) = '1' then
						-- Data Lost
					elsif databus(1 downto 1) = '1' then
						-- FIFO Full
						State <= Get;
					elsif databus(0 downto 0) = '1' then
						-- FIFO Empty
					else
						state <= Idle;
					end if;
					
				when Get =>
					adr <= "101";		-- Setter adresse til å motta data fra Rx
					if (RxData /= databus) then	-- Venter på dataen er mottat fra Rx
						TxData <= databus;	-- Gjør dataen klar for sending til Tx
						state <= Send;		-- Setter status til sending
					else
						State <= Get;
					end if;

				when Send =>
					adr <= "010";							-- Sjekker om Tx er klar til å motta data
					if (databus = "00000000" and snd = '1') then	-- Venter til Tx er klar og sendeknapp er initiert
						adr <= "001";							-- Setter adresse for sending av data til Tx
						databus <= TxData; 					-- Sender data til Tx
						databus <= (others <= '0');		-- Tilbakestiller databussen og gjøres klar til Idle status etter sending
						state <= Idle;
					else 
						state <= Send;
					end if;
			end case;
		end if;
	end process;
end architecture;