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
	type	 State_Type is (Start, Write_Tx_Config, Finish, Idle, Get, Send);
	signal State : State_Type;
	
	
	--type startseq is (start, Write_Rx_Config, Write_Tx_Config, Finish);
	--signal State_init : startseq := start;  -- Initialize to Idle

	signal RxData 		: std_logic_vector(7 downto 0);
	signal TxData 		: std_logic_vector(7 downto 0);
	--signal addr			: std_logic_vector(2 downto 0);
	signal led_state	: std_logic := '1'; 
	signal counter		: integer := 0;
	constant timer_period : integer := 1;  --- NB!!!!!! Husk å endre tilbake til 50000000/20 for 50ms intervaller
	
	
	
	signal sndfor : std_logic ; --- hjelpe signaler for å lage trykk knappen
	signal sndnaa : std_logic ;
	signal blink  : std_logic;
	
	
	
begin


process (clk)
begin
	if (rising_edge(clk)) then
		if blink = '1' then
			-- BLINK LED ------------------------------------
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
end process;



process (clk, rst) --- konfiguerer rx og tx ved start
begin
    if rst = '0' then
        State <= start;
		  
        snd_led <= '1'; ---- led på / default
        
        -- start verdi
        addr 		<= (others => '1');
        databus	<= (others => 'Z');
        RxData 	<= (others => '0');
        TxData 	<= (others => '0');
        wr <= '0';  -- reset write
        rd <= '0';  -- reset read
		  
        
    elsif rising_edge(clk) then
        case State is
        
            when start =>
                --konfigurerer rx
		snd_led <= '1';
		wr <= '1';				-- write
                addr <= "100";  		-- Addresse rx
                databus <= "000" & par_sel & baud_sel;
                State <= Write_Tx_Config;
            
            when Write_Tx_Config =>
                --konfigurerer tx
                addr <= "000";  -- Addresse  Tx
                databus <= "000" & par_sel & baud_sel;
                State <= Finish;
            
            when Finish =>
                -- etter inialisering
					 wr <= '0';-- slutt å skrive
                databus <= (others => 'Z');
					 RxData <= (others => 'Z'); 
					 TxData <= (others => 'Z');
                addr <= (others => '1');
                State <= Idle;
                -- addresse bus er tatt til ubrukt adresse
		
				when Idle =>
					databus <= (others => 'Z');
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
					
					if (databus(0) = '1') then
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
						
				when Get =>
					addr <= "101";		-- Setter addresse til å motta data fra Rx
					rd <= '1'; -- lese
					
					if (RxData /= databus) then	-- Venter på dataen er mottat fra Rx
						rd <= '0';
						TxData <= databus;	-- Gjør dataen klar for sending til Tx
						databus <= (others => 'Z');		-- og resetter databussen til tristate
						state <= Send;		-- Setter status til sending
					else
						State <= Get;
					end if;	
					
					
					
				when Send =>
						addr <= "010";							-- Sjekker om Tx er klar til å motta data
						rd <= '1'; -- lese
						--sndnaa <= snd;
						if (addr = "010") then
							if (databus = "00000001") then
								blink <= '1';
							else 
								blink <= '0';
							end if;
						end if;
						--sndnaa <= sndfor;    -- Store the last state in sndaa
           					--sndfor <= snd;  ------ logikk for at karakter sender kun en gang ved trykk av en knapp
							-- TX BUSY
						--sndnaa = '0' and sndfor ='1'
						
						if (databus = "ZZZZZZZZ" and snd='1') then	-- Venter til Tx er klar og sendeknapp er initiert
							addr <= "001";							-- Setter addresse for sending av data til Tx
							rd <= '0';
							wr <= '1'; -- skrive
							databus <= TxData; 					-- Sender data til Tx
							--databus <= (others => 'Z');		-- Tilbakestiller databussen og gjøres klar til Idle status etter sending
							state <= Idle;
							
						else
							state <= Send;
						
						end if;
				end case;		
			END IF;
		end process;
end architecture;