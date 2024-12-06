-- config_pkg - board specific configuration

library ieee;
use ieee.std_logic_1164.all;

package config_pkg is
	constant HAS_RST : std_logic := '1';
	constant RST_ACTIVE : std_logic := '0';
	constant LED_ACTIVE : std_logic := '0';
	constant CONFIG_MEM_RTL_AREG : std_logic := '1';
	constant PLL_ARCH : string := "GWRPLL";
	constant PLL_FREQ_MHZ : real := 27.0;
	constant PLL_IN_DIV : integer := 1;
	constant PLL_IN_MUL : integer := 16;
	constant PLL_OUT0_DIV : integer := 8; -- 54 MHz
end package;

package body config_pkg is
end;
