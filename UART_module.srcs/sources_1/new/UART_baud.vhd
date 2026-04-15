library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
--use IEEE.NUMERIC_STD.ALL;

-- This needs to create the selected clock for the baud rate from the master CLK100MHZ, however we will give 8x oversampling for the input to give lots of 
-- sampling points to make sure we capture the incomming bits accurately.

entity UART_baud is 
    port(
    
    CLK100MHZ : in std_logic;

    tx_clock : out std_logic;
    rx_clock : out std_logic
    
    )
end UART_baud;

architecture Behavioral of UART_baud is

begin


end Behavioral;
