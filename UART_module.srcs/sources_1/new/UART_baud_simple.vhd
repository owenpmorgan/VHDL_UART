library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This is the simpler internal variable based design

-- This needs to create the selected clock for the baud rate from the master CLK100MHZ, however we will give 8x oversampling for the input to give lots of 
-- sampling points to make sure we capture the incomming bits accurately.

-- Baud Rate 19200, so we need to divide down 100MHz to 19200, and to 307200. Stick with 307200 as we can divide down to 19200 easily

-- 100e6 / 307200 = 325.5208; So a tick at 307200 happens every ~326 clock cycles

-- Use a mod-m counter. M is the limit, M, in our case 307200
-- N is the number of bits needed
-- Log2(307200) = 19 bits needed


entity UART_baud_clock_simple is 
    generic(
        N               : integer := 9; -- bits needed...
        M               : integer := 326 -- ... to count to this to give us the faster 16x baud rate
        );
    port(
    CLK100MHZ           : in std_logic;
    reset               : in std_logic;

    tx_pulse            : out std_logic; -- a pulse at baud rate, 19200
    rx_pulse            : out std_logic -- A pulse at 16x Baud rate 307200, S_TICK in UART_rx
    );
end UART_baud_clock_simple;

architecture arch of UART_baud_clock_simple is

    -- this is the synchronous part
    signal rx_counter        : integer range 0 to M-1 := 0; -- The register that will hold the count
    signal tx_counter        : integer range 0 to 15 := 0; -- The register that holds the 16 times slower count, 0-15

begin

    process(CLK100MHZ, reset)

    begin
        if (reset = '1') then
            rx_counter <= 0;
            tx_counter <= 0;
            rx_pulse <= '0';
            tx_pulse <= '0';

        elsif (CLK100MHZ'event and CLK100MHZ = '1') then
            
            if rx_counter < M-1 then
                rx_counter <= rx_counter + 1;
                rx_pulse <= '0';
                tx_pulse <= '0';
            else
                rx_counter <= 0;
                rx_pulse <= '1';

                if tx_counter < 15 then
                    tx_counter <= tx_counter + 1;
                    tx_pulse <= '0';
                else 
                    tx_counter <= 0;
                    tx_pulse <= '1';
                end if;
            
            end if;

        end if;

    end process;

end arch;
