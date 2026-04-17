----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.04.2026 15:17:34
-- Design Name: 
-- Module Name: UART_top - Behavioral
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


entity UART_top is
  Port ( 
  CLK100MHZ : in std_logic;
  reset     : in std_logic;
  
  RX        : in std_logic;
  TX        : out std_logic;
  
  RX_DONE   : out std_logic;
  TX_DONE   : out std_logic;
  
  d_in      : in std_logic_vector (7 downto 0);
  d_out     : out std_logic_vector (7 downto 0)

   );
end UART_top;

architecture Behavioral of UART_top is

        signal tx_pulse_line : std_logic;
        signal rx_pulse_line : std_logic;

begin

    baud_clock : entity work.UART_baud_clock
        port map(
        
        CLK100MHZ => CLK100MHZ,
        reset => reset,
        
        tx_pulse => tx_pulse_line,
        rx_pulse => rx_pulse_line

         );
         
    rx_module : entity work.UART_rx
         port map(
         
         rx_pulse => rx_pulse_line,
         reset => reset,        
                         
         rx => RX,
         RX_DONE_TICK => RX_DONE,  
         d_out => d_out   
         );
                
     tx_module : entity work.UART_tx
         port map(

        tx_pulse => tx_pulse_line,
        reset => reset,

        tx => TX,

        TX_DONE_TICK  => TX_DONE,

        d_in => d_in
        );



end Behavioral;
