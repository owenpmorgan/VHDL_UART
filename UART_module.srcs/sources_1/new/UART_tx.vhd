library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity UART_tx is
  Generic(
    D_BIT           : integer := 8; -- # Data Bits
    SB_TICK         : integer := 16 -- # Stop ticks
  );
  Port (
    rx_pulse        : in std_logic; -- take the rx pulse and count to 16 for now
    reset           : in std_logic;

    TX_START        : in std_logic;
    
    tx              : out std_logic; -- the physical output
 
    TX_DONE_TICK    : out std_logic;
    d_in            : in std_logic_vector (7 downto 0) -- The paralel data in
   );
end UART_tx;

architecture Behavioral of UART_tx is


    type state_type is (idle, start, data, stop);

    signal state_reg, state_next : state_type;
    signal s_reg, s_next : unsigned(3 downto 0); -- I think this is the ticks counter
    signal n_reg, n_next : unsigned(2 downto 0); -- Num bits sent
    signal b_reg, b_next : std_logic_vector(7 downto 0); -- output data register
    signal tx_reg, tx_next : std_logic; -- serial output data register

begin

    -- The synchronous bit
    Process(rx_pulse, reset)
      if (reset = '1') then
        state_reg <= idle;
        s_reg <= (others => '0');
        n_reg <= (others => '0');
        b_reg <= (others => '0');
        tx_reg <= '1'; -- Remeber UART pulls this low to begin

      elsif rising_edge(rx_pulse) then
        state_reg <= state_next;
        s_reg <= s_next;
        n_reg <= n_next;
        b_reg <= b_next;
        tx_reg <= tx_next;
      end if;

      -- the combinational bit
    Process(state_reg, s_reg, n_reg, b_reg, rx_pulse, tx_reg, tx_start, d_in)
      
      state_next <= state_reg; -- this is saying, by default, stay the same. Covers the case that every output 
      s_next <= s_reg; -- needs to be assigned somethingm then the case statements below selectively update them as needed
      b_next <= b_reg; -- to different things.
      tx_next <= tx_reg ; -- Without this we are inferring that some reg that is not touched in the current loop of cases may
      TX_DONE_TICK <= 0; -- stay unchanged, and the synthesiser has to make a latch, which are more tricky to use and generally avoided.

      case state_reg is
        
        when idle =>
          tx_next <= '1'; -- keep tx high, ie no transaction
          
          if TX_START = '1' then
              state_next <= start;
              s_next <= (others => '0'); -- Start the tick counter
              b_next <= d_in; -- load the b data reg with the d_in data
          end if;
        
        when start =>
            tx_next <= '0'; -- pull the tx line low to initiate
            if rx_pulse = '1' then
              if s_reg = 15 then
                s_next <= (others => '0'); -- reset the tick counter
                n_reg <= (others => '0'); -- n is num data bits sent, reset
                state_next <= data;
              else
                s_next <= s_reg + 1;
              end if;
            end if;

          when data =>
            tx_next <= b_reg(0); -- feed out LSB first
            if rx_pulse = '1' then
              if s_reg = 15 then
                s_next <= (others <= '0'); -- rest the tick counter
                b_next <= '0' & b_reg(7 downto 1) -- LSB has been sent, shuffle array down and fill with zeros
                if n_reg = (D_BIT - 1) then
                  state_next <= stop;
                else
                  n_next <= n_reg + 1;
                end if;
              else 
                s_next <= s_reg + 1;
              end if;
            end if;

            when stop =>
              tx_next <= 1; -- pull back high to indicate idle
              if (rx_pulse = 1) then
                if s_reg <= (SB_TICK-1) then
                  state_next <= idle;
                  TX_DONE_TICK <= '1'
                else
                  s_next <= s_reg + 1;
                end if;
              end if;
      end case;
    end process;

    tx <= tx_reg;

end Behavioral;
