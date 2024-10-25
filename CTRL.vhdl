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
	wr : out std_logic);
	rd : out std_logic);
end entity CTRL;

architecture RTL of CTRL is
	type	 State_Type is (Idle, Get, Send);
	signal State : State_Type;
	
	
	type startseq is (start, Write_Rx_Config, Write_Tx_Config, Finish);
	signal State : startseq := start;  -- Initialize to Idle

	signal RxData 	: std_logic_vector(7 downto 0);
	signal TxData 	: std_logic_vector(7 downto 0);
	signal adr		: std_logic_vector(2 downto 0);
	
	
	signal sndfor : std_logic_vector = '1'; --- hjelpe signaler for å lage trykk knappen
	signal sndnaa : std_logic_vector = '0';
	
begin
    u_ctrl : CTRL
    port map (
        clk         => clk,
        rst         => rst,
        snd => snd,
        --tx_ready    => tx_ready,              -- CTRL indicates when ready for TX
        --rx_ready    => rx_ready,              -- Data ready signal from RX module
        snd_led    => snd_led,              -- Control LED for data reception
        baud_sel => baud_sel,           -- Baud rate control signal
        par_sel => par_sel        -- Parity control signal
    );
process (clk, rst) --- konfiguerer rx og tx ved start
begin
    if (rst = '0') then
        State <= start;
        snd_led <= '1';
        
        -- start verdi
        adr <= (others => '0');
        databus <= (others => '0');
        RxData <= (others => '0');
        TxData <= (others => '0');
        wr <= '0';  -- reset write
        rd <= '0';  -- reset read
        
    elsif rising_edge(clk) then 
        case State is
        
            when start =>
                --konfigurerer rx
                adr <= "100";  -- Addresse rx
                RxData(2 downto 0) <= baud_sel;
                RxData(4 downto 3) <= par_sel;
                databus <= RxData;
                wr <= '1';  -- skrive
                State <= Write_Tx_Config;
            
            when Write_Tx_Config =>
                --konfigurerer tx
                adr <= "000";  -- Addresse  Tx 
                TxData(2 downto 0) <= baud_sel;
                TxData(4 downto 3) <= par_sel;
                databus <= TxData;
                wr <= '1';  -- skrive
                State <= Finish;
            
            when Finish =>
                -- etter inialisering
                wr <= '0';  -- slutt å skrive
                databus <= (others => '0');
					 RxData, TxData <= databus;
                adr <= (others => '0');
                State <= start;
                -- addresse bus er tatt til null
            when others =>
                State <= start;
				end case;
			end if;

		
	
			
		elsif (rising_edge(clk)) then
			case State is
				when Idle =>	
				adr <= "110"    ------- addresse for hvor den skal lese
				
				--rd <= 1;  LESE?
				
				
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
				
				--if databus(0 downto 0)= '1' then
						-- TX BUSY
					--else;	SKAL VI HA DETTE SÅNNN AT DEN GJØR NOE VIS DEN ER BUSY?

				
					sndfor <= snd;
					if (databus = "00000000" and sndfor = '0' and sndnaa ='1' ) then	-- Venter til Tx er klar og sendeknapp er initiert
						adr <= "001";							-- Setter adresse for sending av data til Tx
						databus <= TxData; 					-- Sender data til Tx
						databus <= (others <= '0');		-- Tilbakestiller databussen og gjøres klar til Idle status etter sending
						state <= Idle;
					else 
						state <= Send;
					end if;
					sndnaa <= sndfor; ------ logikk for at karakter sender kun en gang ved trykk av en knapp
			end case;
		end if;
	end process;
end architecture;