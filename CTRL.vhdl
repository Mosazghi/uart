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
	snd_led	: out 	std_logic;
	wr 		: out 	std_logic;
	rd 		: out 	std_logic;
	addr 		: inout	std_logic_vector(2 downto 0)
	);
end entity;


architecture RTL of CTRL is
	type	 State_Type is (Write_Rx_Config, Write_Tx_Config, Config_Finish, Idle, Get, Send);
	signal State : State_Type;
	

	signal RxData 				: std_logic_vector(7 downto 0);
	signal TxData 				: std_logic_vector(7 downto 0);
	signal led_state			: std_logic	:= '1'; 
	signal counter				: integer 	:= 0;
	signal sndnaa 				: std_logic := '0';
	signal blink  				: std_logic := '0';
	constant timer_period	: integer 	:= 50000000/20;	
	
begin

-- Blinking LED process
ledBlink: process (clk)
begin
	if (rising_edge(clk)) then
		if blink = '1' then
			if counter < timer_period then
				counter  <=	counter +1;
			else 
				counter <= 0;
				led_state <= not led_state;
			end if;
		else
			counter <= 0;
			led_state <= '1';
		end if;
	end if;
end process ledBlink;

-- Main process
process (clk, rst)
begin
	if rst = '0' then
		State <= Write_Rx_Config;

		-- Setting default values
      addr		<= (others => 'Z');
      databus	<= (others => 'Z');
      RxData	<= (others => '0');
      TxData	<= (others => '0');
      wr			<= '0';
      rd			<= '0';
		snd_led	<= '1'; -- LED on by default
		  
        
	elsif rising_edge(clk) then
		case State is
		
			when Write_Rx_Config => -- Configuring Baudrate and Parity selection of Rx
				wr 		<= '1'; 		-- Writing in progress indication
            addr 		<= "100";	-- Address for Rx Configuration
            databus	<= "000" & par_sel & baud_sel;
            State		<= Write_Tx_Config;
            
			when Write_Tx_Config => -- Configuring Baudrate and Parity selection of Tx
            addr <= "000"; 		-- Address for Rx Configuration
            databus <= "000" & par_sel & baud_sel;
            State <= Config_Finish;
           
			when Config_Finish =>
				wr <= '0';
            databus <= (others => 'Z');
				RxData <= (others => '0'); 
				TxData <= (others => '0');
            addr <= (others => 'Z');
            State <= Idle;
            -- addresse bus er tatt til ubrukt adresse
				
			when Idle =>
				if (databus = TxData) then
					databus <= (others => 'Z');
					TxData <= (others => '0');
				else
					addr <= "110";    ------- addresse for hvor den skal lese
					wr <= '0'; -- ikke skrive
					rd <= '1'; -- lese	
					-- Statusene skal er ikke tilgjengelig før neste klokke syklus, så inkluder enda en tilstand.
						
					---------------disse er ikke strengt tatt viktig for oppgaven
						
					-- Sjekker Rx status 
/*	
					if (databus(3) = '1') then
						-- Parity Error
						state <= Idle;
					end if;
							
					if (databus(2) = '1') then
						-- Data Lost	
						state <= Idle;
					end if;
						
					if (databus(0) = '0') then
						-- FIFO Empty
						state <= Idle; -- vente på data
					end if;
*/	
					if (databus(1) = '0') then
						-- FIFO Full
						--state <= Idle;
						RxData <= databus;
						State <= Get; ----------------- teste dette i testbench
						rd <= '0';
					else 
						State <= Idle;
					end if;
				end if;	
			when Get =>
				addr <= "101";		-- Setter addresse til å motta data fra Rx
				rd <= '1'; -- lese
					
				if (RxData /= databus) then	-- Venter på dataen er mottat fra Rx
					rd <= '0';
					TxData <= databus;	-- Gjør dataen klar for sending til Tx
					RxData <= (others => '0');
					databus <= (others => 'Z');		-- og resetter databussen til tristate
					state <= Send;		-- Setter status til sending
				else
					State <= Get;
				end if;	
						
			when Send =>
				addr <= "010";							-- Sjekker om Tx er klar til å motta data
				rd <= '1'; -- lese
				sndnaa <= snd;
				if (addr = "010") then
					if (databus = "00000001") then
						blink <= '1';
					else 
						blink <= '0';
					end if;
				end if;
				
				snd_led <= led_state;
				-- TX BUSY
				if (databus = "ZZZZZZZZ" and sndnaa = '1') then	-- Venter til Tx er klar og sendeknapp er initiert
					addr <= "001";							-- Setter addresse for sending av data til Tx
					rd <= '0';
					wr <= '1'; -- skrive
					databus <= TxData; 					-- Sender data til Tx
					state <= Idle;
				else
					state <= Send;	
				end if;
			end case;		
		end if;
	end process;
end architecture;