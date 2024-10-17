entity RX is 
  Port ( clk : in  STD_LOGIC;
         reset : in  STD_LOGIC;
         data_in : in  STD_LOGIC;
         data_out : out  STD_LOGIC;
         data_valid : out  STD_LOGIC;
         data_ready : in  STD_LOGIC);
end RX;



-- case addr 
-- when 100 => 
