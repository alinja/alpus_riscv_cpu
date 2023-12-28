-- alpus_wb32_pkg - package for 32-bit Wishbone bus signalling

library ieee;
use ieee.std_logic_1164.all;

package alpus_wb32_pkg is
	-- Wishbone signals to slave direction
	type alpus_wb32_tos_t is record
		cyc    : std_logic; -- bus cycle
		we     : std_logic; -- wr cycle (rd_n)
		stb    : std_logic; -- transfer cycle, slave select
		adr    : std_logic_vector(31 downto 0); -- BYTE address
		data   : std_logic_vector(31 downto 0);
		sel    : std_logic_vector(3 downto 0); -- write enable
		--tgd    : std_logic;
		--tga    : std_logic;
		--tgc    : std_logic;
		--lock    : std_logic;
	end record alpus_wb32_tos_t;  
  
	-- Wishbone signals to master direction
	type alpus_wb32_tom_t is record
		data  : std_logic_vector(31 downto 0);
		stall : std_logic;
		ack    : std_logic; -- bus cycle ack
		--tgd    : std_logic;
		--err    : std_logic; -- bus cycle nack
		--rty    : std_logic; -- bus cycle ->retry
	end record alpus_wb32_tom_t;  
	
	-- Initial/idle values
	constant alpus_wb32_tos_init : alpus_wb32_tos_t := ('0', '0', '0', (others => '0'), (others => '0'), (others => '0'));
	constant alpus_wb32_tom_init : alpus_wb32_tom_t := ((others => '0'), '0', '0');


end package;

package body alpus_wb32_pkg is

end;
