library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity RX is 
  port ( clk : in  std_logic;
         reset : in  std_logic;
          RxD : in  std_logic;
          data_bus : inout  std_logic_vector(11 downto 0);
          par_sel : in  std_logic;
          buad_sel : in  std_logic;
          fifo_full : out  std_logic;
          fifo_empty : out  std_logic;
          data_lost : out  std_logic;
          parity_err : out  std_logic
        );
end RX;


architecture RTL of RX is
  
begin
  
  
  
end architecture RTL;
