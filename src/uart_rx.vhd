library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx is
  generic (
    CLK_FREQ  : integer := 50000000;
    BAUD_RATE : integer := 115200
  );
  port (
    clk        : in  std_logic;
    rst        : in  std_logic;
    rx         : in  std_logic;
    data_out   : out std_logic_vector(7 downto 0);
    data_valid : out std_logic
  );
end uart_rx;

architecture Behavioral of uart_rx is

  constant CLKS_PER_BIT : integer := CLK_FREQ / BAUD_RATE;

  type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
  signal state     : state_type := IDLE;
  signal clk_count : integer range 0 to CLKS_PER_BIT - 1 := 0;
  signal bit_index : integer range 0 to 7 := 0;
  signal rx_byte   : std_logic_vector(7 downto 0) := (others => '0');

begin

  process(clk)
  begin
    if rising_edge(clk) then
      data_valid <= '0';
      if rst = '1' then
        state     <= IDLE;
        clk_count <= 0;
        bit_index <= 0;
      else
        case state is
          when IDLE =>
            if rx = '0' then
              clk_count <= 0;
              state     <= START_BIT;
            end if;
          when START_BIT =>
            if clk_count = CLKS_PER_BIT / 2 then
              if rx = '0' then
                clk_count <= 0;
                state     <= DATA_BITS;
              else
                state <= IDLE;
              end if;
            else
              clk_count <= clk_count + 1;
            end if;
          when DATA_BITS =>
            if clk_count < CLKS_PER_BIT - 1 then
              clk_count <= clk_count + 1;
            else
              clk_count        <= 0;
              rx_byte(bit_index) <= rx;
              if bit_index < 7 then
                bit_index <= bit_index + 1;
              else
                bit_index <= 0;
                state     <= STOP_BIT;
              end if;
            end if;
          when STOP_BIT =>
            if clk_count < CLKS_PER_BIT - 1 then
              clk_count <= clk_count + 1;
            else
              data_valid <= '1';
              data_out   <= rx_byte;
              clk_count  <= 0;
              state      <= IDLE;
            end if;
          when others =>
            state <= IDLE;
        end case;
      end if;
    end if;
  end process;

end Behavioral;