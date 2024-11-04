library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package uart_library is
	constant CLOCK_FREQ_HZ : integer := 50_000_000/10; 
  -- Baud Rate       Divider
  constant DIV_9600     : integer := 5208;  -- 9600 baud
  constant DIV_19200    : integer := 2604;  -- 19200 baud
  constant DIV_38400    : integer := 1302;  -- 38400 baud
  constant DIV_57600    : integer := 868;   -- 57600 baud
  constant DIV_115200   : integer := 434;   -- 115200 baud

  -- Array of baud rate dividers for easy lookup
  type baud_div_array is array (0 to 4) of integer;
  constant baud_dividers : baud_div_array := (
    DIV_115200,   -- "100" => 115200 baud
    DIV_57600,   -- "011" => 57600 baud
    DIV_38400,   -- "010" => 38400 baud
    DIV_19200,   -- "001" => 19200 baud
    DIV_9600    -- "000" => 9600 baud
  );


  -- Address constants for TX registers
  constant TX_CONFIG_A  : std_logic_vector(2 downto 0) := "000";
  constant TX_DATA_A    : std_logic_vector(2 downto 0) := "001";
  constant TX_STATUS_A  : std_logic_vector(2 downto 0) := "010";

  -- Address constants for RX registers
  constant RX_CONFIG_A  : std_logic_vector(2 downto 0) := "100";
  constant RX_DATA_A    : std_logic_vector(2 downto 0) := "101";
  constant RX_STATUS_A  : std_logic_vector(2 downto 0) := "110";

  -- Index constants for TxCONFIG
  constant TX_PARITY_S  : integer := 4;
  constant TX_PARITY_E  : integer := 3;
  constant TX_BAUD_S    : integer := 2;
  constant TX_BAUD_E    : integer := 0;

  -- Index constants for TxDATA
  constant TX_DATA_S    : integer := 7;
  constant TX_DATA_E    : integer := 0;

  -- Index constants for TxSTATUS
  constant TX_BUSY_S    : integer := 0;   -- Only one bit, start and end are the same

  -- Index constants for RxCONFIG
  constant RX_PARITY_S  : integer := 4;
  constant RX_PARITY_E  : integer := 3;
  constant RX_BAUD_S    : integer := 2;
  constant RX_BAUD_E    : integer := 0;

  -- Index constants for RxDATA
  constant RX_DATA_S    : integer := 7; 
  constant RX_DATA_E    : integer := 0;

  -- Index constants for RxSTATUS
  constant RX_PE_S      : integer := 3;  -- Parity Error
  constant RX_DL_S      : integer := 2;  -- Data Lost
  constant RX_FF_S      : integer := 1;  -- FIFO Full
  constant RX_FE_S      : integer := 0;  -- FIFO Empty

  -- Number of data bits
  constant DATA_BITS_N : integer := 8;
  constant ADDR_BITS_N : integer := 3;


end package uart_library;

package body uart_library is
end package body uart_library;
