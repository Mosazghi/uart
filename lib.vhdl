library ieee; 
use ieee.std_logic_1164.all; 

package uart_library is
  type data_bus is record 
    data : std_logic_vector(7 downto 0);
    addr : std_logic_vector(2 downto 0);
    wr : std_logic;
    rd : std_logic;
    end record data_bus;


end package uart_library;


package body uart_library is 
end package body uart_library;
