----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 14.04.2026 21:21:28
-- Design Name: 
-- Module Name: UART_tx - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity UART_tx is
  Generic(
    D_BIT           : integer := 8; -- # Data Bits
    SB_TICK         : integer := 16 -- # Stop ticks
  );
  Port (
    tx_pulse        : in std_logic; -- 
    reset           : in std_logic;
    
    tx              : out std_logic; -- the physical output
 
    TX_DONE_TICK    : out std_logic;
    d_in            : in std_logic_vector (7 downto 0) -- The paralel data in
   );
end UART_tx;

architecture Behavioral of UART_tx is

begin


end Behavioral;
