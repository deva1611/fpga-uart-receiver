library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity uart_rx_tb is
end uart_rx_tb;

architecture Behavioral of uart_rx_tb is

  constant CLK_PERIOD : time := 20 ns;
  constant BIT_PERIOD : time := 8680 ns;

  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';
  signal rx         : std_logic := '1';
  signal data_out   : std_logic_vector(7 downto 0);
  signal data_valid : std_logic;

  procedure send_byte (
    constant byte_val : in std_logic_vector(7 downto 0);
    signal tx_line    : out std_logic
  ) is
  begin
    tx_line <= '0';
    wait for BIT_PERIOD;
    for i in 0 to 7 loop
      tx_line <= byte_val(i);
      wait for BIT_PERIOD;
    end loop;
    tx_line <= '1';
    wait for BIT_PERIOD / 2;
    end procedure;

begin

  DUT: entity work.uart_rx
    generic map (
      CLK_FREQ  => 50000000,
      BAUD_RATE => 115200
    )
    port map (
      clk        => clk,
      rst        => rst,
      rx         => rx,
      data_out   => data_out,
      data_valid => data_valid
    );

  clk <= not clk after CLK_PERIOD / 2;

  process
  begin
    wait for 200 ns;
    rst <= '0';
    wait for 500 ns;

    -- TEST 1: 0x55
    report "Test 1: Sending 0x55";
    send_byte(x"55", rx);
    wait until data_valid = '1';
    wait for CLK_PERIOD;
    assert data_out = x"55"
      report "FAIL Test 1: expected 0x55"
      severity error;
    report "PASS Test 1: 0x55 received correctly";
    wait for BIT_PERIOD * 2;

    -- TEST 2: 0xA3
    report "Test 2: Sending 0xA3";
    send_byte(x"A3", rx);
    wait until data_valid = '1';
    wait for CLK_PERIOD;
    assert data_out = x"A3"
      report "FAIL Test 2: expected 0xA3"
      severity error;
    report "PASS Test 2: 0xA3 received correctly";
    wait for BIT_PERIOD * 2;

    -- TEST 3: 0x00
    report "Test 3: Sending 0x00";
    send_byte(x"00", rx);
    wait until data_valid = '1';
    wait for CLK_PERIOD;
    assert data_out = x"00"
      report "FAIL Test 3: expected 0x00"
      severity error;
    report "PASS Test 3: 0x00 received correctly";
    wait for BIT_PERIOD * 2;

    -- TEST 4: 0xFF
    report "Test 4: Sending 0xFF";
    send_byte(x"FF", rx);
    wait until data_valid = '1';
    wait for CLK_PERIOD;
    assert data_out = x"FF"
      report "FAIL Test 4: expected 0xFF"
      severity error;
    report "PASS Test 4: 0xFF received correctly";
    wait for BIT_PERIOD * 2;

    report "==============================";
    report "ALL 4 TESTS PASSED";
    report "==============================";
    wait;
  end process;

end Behavioral;