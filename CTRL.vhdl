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
	signal sndnaa 				: std_logic := '0';
	signal sndfor				: std_logic := '0';
	signal blink  				: std_logic := '0';
	signal counter				: integer 	:= 0;
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
main_proc: process (clk, rst)
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
		sndnaa 	<= '0';
		sndfor	<= '0';
		blink 	<= '0';		  
        
	elsif rising_edge(clk) then
		databus <= (others => 'Z');
		case State is
			when Write_Rx_Config => -- Configuring Baudrate and Parity selection of Rx
				wr 		<= '1'; 		-- Writing in progress indication
            addr 		<= "100";	-- Address for Rx Configuration
            databus	<= "000" & par_sel & baud_sel;
            State		<= Write_Tx_Config;
            
			when Write_Tx_Config => -- Configuring Baudrate and Parity selection of Tx
            addr 		<= "000"; 		-- Address for Rx Configuration
            databus	<= "000" & par_sel & baud_sel;
            State		<= Config_Finish;
           
			when Config_Finish =>
				-- Setting default values
				wr			<= '0';
            databus	<= (others => 'Z');
				addr		<= (others => 'Z');
				RxData 	<= (others => '0'); 
				TxData 	<= (others => '0');
            State		<= Idle;
				
				
			when Idle =>
				if (databus = TxData) then 	-- Hindrer data som blir sendt ikke overføres inn i idle
					databus	<= (others => 'Z');
					TxData	<= (others => '0');
				else
					addr <= "110";
					wr <= '0';	rd <= '1';

					-- Parity Error
					if (databus(3) = '1') then
						state <= Idle;
					end if;
					
					-- Data Lost
					if (databus(2) = '1') then	
						state <= Idle;
					end if;
					
					-- FIFO Empty
					if (databus(0) = '0') then
						state <= Idle; 	-- Rx doesn't have data to transfer
					end if;
					
					-- FIFO Full
					if (databus(1) = '0') then
						RxData	<= databus;
						State		<= Get;
						rd			<= '0';
					else 
						State <= Idle;
					end if;
				end if;
				
			when Get =>
				addr <= "101"; -- Address for receiving data from Rx
				rd <= '1';
					
				if (RxData /= databus) then		-- Waiting on data from Rx
					rd <= '0';
					TxData <= databus;				-- Stores data from Rx on its own vector
					RxData <= (others => '0');		-- Resets Rx vector
					databus <= (others => 'Z');	-- Resets the databus
					state <= Send;
				else
					State <= Get;
				end if;	
						
			when Send =>
				addr <= "010";	-- Sets address to Tx status check
				rd <= '1';
				sndfor <= snd;
				if (addr = "010") then
					if (databus = "00000001") then	-- Blinks while Tx is busy, i.e sending data
						blink <= '1';
					else 
						blink <= '0';
					end if;
				end if;
				snd_led <= led_state;
				
				if (databus = "00000001" and sndfor = '1') then -- Holds button state while Tx is busy
					sndnaa <= sndfor;
				end if;
				
				if (databus = "ZZZZZZZZ" and (sndfor = '1' or sndnaa = '1')) then	-- Sends data to Tx when Tx is ready and send key is initialized
					addr 		<= "001";	-- Address for data sending to Tx
					rd 		<= '0';
					wr 		<= '1';
					databus	<= TxData;
					state 	<= Idle;
					sndnaa 	<= '0';
				else
					state 	<= Send;	
				end if;
			end case;		
		end if;
	end process main_proc;
end architecture RTL;