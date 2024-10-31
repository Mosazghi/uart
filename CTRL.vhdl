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
	addr 		: inout		std_logic_vector(2 downto 0)
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
	constant timer_period : integer := 50000000 / 20;  
	
	
	
	signal sndfor : std_logic := '1'; --- hjelpe signaler for å lage trykk knappen
	signal sndnaa : std_logic := '0';
	
	procedure RoW(num : std_logic) is  -- Is this Read or Write;-;
	begin
		if (num = '0') then
			rd <= '1';
			wr <= '0';
		else 
			rd <= '0';
			wr <= '1';
		end if;
	end procedure;
	
begin

    u_ctrl : CTRL
    port map (
        clk       => clk,
        rst       => rst,
        snd			=> snd,
        snd_led   => snd_led,              -- Control LED for data reception
        baud_sel 	=> baud_sel,           -- Baud rate control signal
        par_sel	=> par_sel,        -- Parity control signal
		  addr		=> addr
		  --tx_ready    => tx_ready,              -- CTRL indicates when ready for TX
        --rx_ready    => rx_ready,              -- Data ready signal from RX module  
    );
	

process (clk, rst) --- konfiguerer rx og tx ved start
begin
    if rst = '0' then
        State <= start;
		  
        led_state <= '1'; ---- led på / default
        
        -- start verdi
        addr 		<= (others => '0');
        databus	<= (others => 'Z');
        RxData 	<= (others => '0');
        TxData 	<= (others => '0');
        wr <= '0';  -- reset write
        rd <= '0';  -- reset read
		  
        
    elsif rising_edge(clk) then
        case State is
        
            when start =>
                --konfigurerer rx
                addr <= "100";  -- Addresse rx
					 
					 databus <= ("00000" & addr);
                RxData(2 downto 0) <= baud_sel;
                RxData(4 downto 3) <= par_sel;
                databus <= RxData;
                Row('1'); -- skrive
                State <= Write_Tx_Config;
            
            when Write_Tx_Config =>
                --konfigurerer tx
                addr <= "000";  -- Addresse  Tx 
                TxData(2 downto 0) <= baud_sel;
                TxData(4 downto 3) <= par_sel;
                databus <= TxData;
                RoW('1');  -- skrive
                State <= Finish;
            
            when Finish =>
                -- etter inialisering
                wr <= '0';  -- slutt å skrive
                databus <= (others => 'Z');
					 RxData <= databus; 
					 TxData <= databus;
                addr <= (others => '0');
                State <= Idle;
                -- addresse bus er tatt til null
		
				when Idle =>	
					addr <= "110";    ------- addresse for hvor den skal lese
					RoW('0'); -- lese
				
					-- Tilbakemelding: bruk en index ikke x downto y for dette. bruk If's for alle. 
					-- Statusene skal er ikke tilgjengelig før neste klokke syklus, så inkluder enda en tilstand.
					
					-- Sjekker Rx status 
					if 	(databus(3) = '1') then
						-- Parity Error
					elsif (databus(2) = '1') then
						-- Data Lost
					elsif (databus(1) = '1') then
						-- FIFO Full
						State <= Get;
					elsif (databus(0) = '1') then
						-- FIFO Empty
					else
						state <= Idle;
					end if;
					
				when Get =>
					addr <= "101";		-- Setter addresse til å motta data fra Rx
					RoW('0'); -- lese
					
					if (RxData /= databus) then	-- Venter på dataen er mottat fra Rx
						TxData <= databus;	-- Gjør dataen klar for sending til Tx
						state <= Send;		-- Setter status til sending
					else
						State <= Get;
					end if;	
					
					
					
				when Send =>
					addr <= "010";							-- Sjekker om Tx er klar til å motta data
					RoW('0'); -- lese
					sndfor <= snd;
					
					if (databus(0)= '1') then
					-- BLINK LED
					------------------------------------
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
					
					snd_led <= led_state;
						-- TX BUSY
					if (databus = "00000000" and sndfor = '0' and sndnaa ='1' ) then	-- Venter til Tx er klar og sendeknapp er initiert
						addr <= "001";							-- Setter addresse for sending av data til Tx
						RoW('1'); -- skrive
						databus <= TxData; 					-- Sender data til Tx
						databus <= (others => 'Z');		-- Tilbakestiller databussen og gjøres klar til Idle status etter sending
						state <= Idle;
					else 
						state <= Send;
					-- Tilbakemelding: husk å sjekke tx_busy osv før man sender
					end if;
					sndnaa <= sndfor; ------ logikk for at karakter sender kun en gang ved trykk av en knapp
			end case;
		end if;
	end process;
end architecture;