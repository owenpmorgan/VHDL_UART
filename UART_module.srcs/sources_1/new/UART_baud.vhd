library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- This code is the formal, explict, next_reg_value version, that is overkill and verbose here but for more complex designas can keep things synchronous
-- better, and easier to spot

-- This needs to create the selected clock for the baud rate from the master CLK100MHZ, however we will give 8x oversampling for the input to give lots of 
-- sampling points to make sure we capture the incomming bits accurately.

-- Baud Rate 19200, so we need to divide down 100MHz to 19200, and to 307200. Stick with 307200 as we can divide down to 19200 easily

-- 100e6 / 307200 = 325.5208; So a tick at 307200 happens every ~326 clock cycles

-- Use a mod-m counter. M is the limit, M, in our case 307200
-- N is the number of bits needed
-- Log2(307200) = 19 bits needed


entity UART_baud_clock is 
    generic(
        N               : integer := 9; -- bits needed...
        M               : integer := 326; -- ... to count to this to give us the faster 16x baud rate
        )
    port(
    CLK100MHZ           : in std_logic;
    reset               : in std_logic;

    tx_pulse            : out std_logic; -- a pulse at baud rate, 19200
    rx_pulse            : out std_logic -- A pulse at 16x Baud rate 307200, S_TICK in UART_rx
    );
end UART_baud_clock;

architecture arch of UART_baud_clock is

    -- this is the synchronous part
    signal rx_reg        : unsigned(N-1 downto 0); -- The register that will hold the count
    signal rx_next       : unsigned(N-1 downto 0); -- A temp reg in which we can compute what the next reg val will be

    signal tx_reg        : unsigned(3 downto 0); -- The register that holds the 16 times slower count, 0-15
    signal tx_next       : unsigned(3 downto 0); -- A temp reg in which we can compute what the next reg val will be

begin

    process(CLK100MHZ, reset)
    begin
        if (reset = '1') then
            rx_reg <= (others => '0');
            tx_reg <= (others => '0');
        elsif (CLK100MHZ'event and CLK100MHZ = '1') then
            rx_reg <= rx_next;
            tx_reg <= tx_next;
    end if;
    end process;

    -- next state logic
    rx_next <= (others => '0') when rx_reg=(M-1) else -- M is the count max
        rx_reg + 1; -- this doesnt increment r_reg here, it make rx_next one

    tx_next <=  (others => '0') when (tx_reg = 15 and rx_pulse = '1') else 
        tx_reg + 1 when rx_pulse = '1' else 
            tx_reg;

    --output logic
    rx_pulse <= '1' when rx_reg = (M-1) else '0';
    tx_pulse <= '1' when (tx_reg = 15 and rx_pulse = '1') else '0';

end arch;
