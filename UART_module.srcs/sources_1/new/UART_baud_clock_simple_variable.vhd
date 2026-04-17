library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- A really simple variable counter based solution

entity UART_baud_clock_simple_variable is 
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
end UART_baud_clock_simple_variable;

architecture Behavioral of UART_baud_clock_simple_variable is
    
begin

    process(CLK100MHZ, reset)
    
        variable rx_v  : unsigned(N-1 downto 0) := (others => '0');
        variable tx_v  : unsigned(3 downto 0) := (others => '0');
        
    begin
        if reset = '1' then
        
            rx_v := (others => '0');
            tx_v := (others => '0');
    
            rx_pulse <= '0';
            tx_pulse <= '0';
    
        elsif rising_edge(CLK100MHZ) then
    
            -- defaults (important)
            rx_pulse <= '0';
            tx_pulse <= '0';
    
            -- RX counter
            if rx_v = M-1 then
                rx_v := (others => '0');
                rx_pulse <= '1';
                if tx_v = 15 then
                    tx_v := (others => '0');
                    tx_pulse <= '1';
                else
                    tx_v := tx_v + 1;
                end if;
            else
                rx_v := rx_v + 1;
            end if;
    
    
        end if;
    end process;
    
end Behavioral;
