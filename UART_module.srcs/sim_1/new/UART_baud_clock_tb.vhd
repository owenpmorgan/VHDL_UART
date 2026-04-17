
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UART_baud_clock_tb is
end UART_baud_clock_tb;

architecture tb_arch of UART_baud_clock_tb is

    signal CLK100MHZ           : std_logic := '0';
    signal reset               : std_logic := '0';

    signal tx_pulse            : std_logic; 
    signal rx_pulse            : std_logic; 

begin

    CLK100MHZ <= not CLK100MHZ after 5 ns;

    uut : entity work.UART_baud_clock_simple_variable
    port map(
    
        CLK100MHZ => CLK100MHZ,
        reset => reset,
        tx_pulse => tx_pulse,
        rx_pulse => rx_pulse
    );

    process
    
    begin
    
        wait for 100 us;
        assert false report "End of Sim" severity failure;
    
    end process;


end tb_arch;
