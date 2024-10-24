library ieee;
use ieee.std_logic_1164.all;

package uart_library is

  -- Address constants for TX registers
  constant TX_CONFIG_ADDR  : std_logic_vector(2 downto 0) := "000";
  constant TX_DATA_ADDR    : std_logic_vector(2 downto 0) := "001";
  constant TX_STATUS_ADDR  : std_logic_vector(2 downto 0) := "010";
  constant TX_NA_ADDR      : std_logic_vector(2 downto 0) := "011";

  -- Address constants for RX registers
  constant RX_CONFIG_ADDR  : std_logic_vector(2 downto 0) := "100";
  constant RX_DATA_ADDR    : std_logic_vector(2 downto 0) := "101";
  constant RX_STATUS_ADDR  : std_logic_vector(2 downto 0) := "110";
  constant RX_NA_ADDR      : std_logic_vector(2 downto 0) := "111";

  -- Index constants for TxCONFIG
  constant TX_PARITY_IDX_START : integer := 4;
  constant TX_PARITY_IDX_END   : integer := 3;
  constant TX_BAUD_IDX_START   : integer := 2;
  constant TX_BAUD_IDX_END     : integer := 0;

  -- Index constants for TxDATA
  constant TX_DATA_IDX_START   : integer := 7;
  constant TX_DATA_IDX_END     : integer := 0;

  -- Index constants for TxSTATUS
  constant TX_BUSY_IDX         : integer := 0;

  -- Index constants for RxCONFIG
  constant RX_PARITY_IDX_START : integer := 4;
  constant RX_PARITY_IDX_END   : integer := 3;
  constant RX_BAUD_IDX_START   : integer := 2;
  constant RX_BAUD_IDX_END     : integer := 0;

  -- Index constants for RxDATA
  constant RX_DATA_IDX_START   : integer := 7;
  constant RX_DATA_IDX_END     : integer := 0;

  -- Index constants for RxSTATUS
  constant RX_PE_IDX           : integer := 3;  -- Parity Error
  constant RX_DL_IDX           : integer := 2;  -- Data Lost
  constant RX_FF_IDX           : integer := 1;  -- FIFO Full
  constant RX_FE_IDX           : integer := 0;  -- FIFO Empty
  
  -- Number of data bits
  constant DATA_BITS_NUM : integer := 8;

end package uart_library;

package body uart_library is
end package body uart_library;
