library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL

-- Baud Rate 19200
-- NO parity bit
-- 8 data bits
-- 1 stop bit

-- 16x oversampling on Rx =  307200 
-- Log2(307200) = 19 bits needed
-- Log2(19200) = 15 bits needed

-- D-BIT = Number of Data Bits
-- SB_TICK = No ticks needed for stop bits, 16, 24 and 32 respectively for 1, 1.5 and 2 stop bits (we use 16)
-- S_TICK = Start tick from Baud rate generator

-- 2 counters, S and N registers
-- S = sampling ticks
-- Counts to 7 in the start state
-- Counts to 15 in the data state
-- COUnts to SB_TICK in the stop state

-- N = Numer of bits received
-- b register = register to assemble the received serial bytes and rearrange into parallel

-- RX_DONE_TICK asserts for one clock cycle after the receiving process is completed

entity UART is
--  Port ( );
end UART;

architecture Behavioral of UART is

begin


end Behavioral;
