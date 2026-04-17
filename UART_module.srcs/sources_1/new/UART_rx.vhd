library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Baud Rate 19200
-- NO parity bit
-- 8 data bits
-- 1 stop bit

-- 16x oversampling on Rx =  307200 
-- Log2(307200) = 19 bits needed
-- Log2(19200) = 15 bits needed

-- D-BIT = # of Data Bits
-- SB_TICK = # ticks needed for stop bits, 16, 24 and 32 respectively for 1, 1.5 and 2 stop bits (we use 16)
-- S_TICK = Sampling tick, we want this to run at 16x baud rate

-- 100e6 / 307200 = 326 clock counts per s_tick

-- 2 counters, S and N registers
-- S = sampling ticks
-- Counts to 7 in the start state
-- Counts to 15 in the data state
-- Counts to SB_TICK in the stop state

-- N = Number of bits received
-- b register = register to assemble the received serial bytes and rearrange into parallel

-- RX_DONE_TICK asserts for one clock cycle after the receiving process is completed

-- This code uses a much more explicit assignment of states, rather than let signals update at end of processes and leave it fairly hard to be sure when things will 
-- happen (they will all happen at defined times but its not explicit in normal code) this code instead uses state_next for most registers that need updating. Rather than
-- assigning a new value to the same signal, eg signal <= signal + 1, we assign it to state_next, and then on the next MASTER clock tick make state next become state. Quite a 
-- nice way of doing things, especially if you know the clock is WAY faster than your design, might be wasteful of cycles if you are runing at close to clock limit.

entity UART_rx is
  Generic(
    D_BIT           : integer := 8; -- # Data Bits
    SB_TICK         : integer := 16 -- # Stop ticks
  );
  Port (
    rx_pulse        : in std_logic; -- 
    reset           : in std_logic;
    
    rx              : in std_logic; -- the physical input
 
    RX_DONE_TICK    : out std_logic;
    d_out           : out std_logic_vector (7 downto 0) -- The parallel data out
   );
end UART_rx;

architecture arch of UART_rx is

    type state_type is (idle, start, data, stop);
    
    signal state_reg, state_next : state_type;
    signal s_reg, s_next : unsigned(3 downto 0); -- I think this is the stop bit ticks counter
    signal n_reg, n_next : unsigned(2 downto 0); -- Num bits received
    signal b_reg, b_next : std_logic_vector(7 downto 0); -- output data register

begin

    -- state and data registers
    process(rx_pulse, reset)
    begin
        if reset = '1' then
            state_reg <= idle;
            s_reg <= (others => '0');
            n_reg <= (others => '0');
            b_reg <= (others => '0');
        elsif rising_edge(rx_pulse) then
            state_reg <= state_next;
            s_reg <= s_next; -- s_next is assigned an incremented s_reg below, this will be asigned to s_reg on the next system clock tick
            n_reg <= n_next;
            b_reg <= b_next;
        end if;
    end process;
    
    process(state_reg, s_reg, n_reg, b_reg, rx_pulse, rx)
    begin      
        state_next <= state_reg; -- perpetuate staying the same if nothing happens, state_next become state_reg on next clock cycle in above process
        s_next <= s_reg;
        n_next <= n_reg;
        b_next <= b_reg;
        rx_done_tick <= '0';
        
        case state_reg is
            
            when idle =>
                if rx='0' then -- rx line low while idle, transaction started
                    state_next <= start;
                    s_next <= (others => '0');
                end if;
            
            when start =>
                if (rx_pulse = '1') then -- s tick is the 16x baud sample tick, when it is 1, it has incremented by one
                    if (s_reg = 7) then -- if the reg holding number of s ticks has reached 7, thats the halfway point in a sample at the baud rate
                        state_next <= data;
                        s_next <= (others => '0'); -- reset sampling ticks
                        n_next <= (others => '0'); -- and num bits recieved
                     else 
                        s_next <= s_reg + 1; -- remember s_next gets assigned to s_reg on every system clock tick in the above process
                     end if;
                 end if;
                 
             when data =>
                if (rx_pulse = '1') then 
                    if (s_reg = 15) then 
                        s_next <= (others => '0');
                        b_next <= rx & b_reg(7 downto 1); -- this will pop off the LSB of b_reg and add the current rx to the MSB, after 8 we will get our 8 bits data
                        if (n_reg = (D_BIT - 1)) then 
                            state_next <= stop;
                        else 
                            n_next <= n_reg + 1;
                        end if;
                    else    
                        s_next <= s_reg + 1;
                    end if;
                end if;

            when stop =>
                if (rx_pulse = '1') then
                    if (s_reg = (SB_TICK -1)) then
                        state_next <= idle;
                        RX_DONE_TICK <= '1';
                    else
                        s_next <= s_reg + 1;
                    end if;
                end if;
            end case;   
        end process;
        
        d_out <= b_reg;
end arch;
