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

	-- Select slave by address and mask
	function alpus_wb32_slave_select_tos(
		adr  : std_logic_vector(31 downto 0);
		mask : std_logic_vector(31 downto 0);
		m : alpus_wb32_tos_t
	) return alpus_wb32_tos_t;

	function alpus_wb32_slave_select_tom(
		adr  : std_logic_vector(31 downto 0); --addr for a
		mask : std_logic_vector(31 downto 0);
		m : alpus_wb32_tos_t;
		a : alpus_wb32_tom_t;
		b : alpus_wb32_tom_t
	) return alpus_wb32_tom_t;

end package;

package body alpus_wb32_pkg is

	function alpus_wb32_slave_select_tos(
		adr  : std_logic_vector(31 downto 0);
		mask : std_logic_vector(31 downto 0);
		m : alpus_wb32_tos_t
	) return alpus_wb32_tos_t is
		variable RET : alpus_wb32_tos_t;
	begin
		if (adr and mask) = (m.adr and mask) then
			return m;
		else
			RET := m;
			RET.cyc := '0';
			RET.we := '0'; --not needed but prettier in simulation
			RET.stb := '0';
			return RET;
		end if;
	end function;

	function alpus_wb32_slave_select_tom(
		adr  : std_logic_vector(31 downto 0);
		mask : std_logic_vector(31 downto 0);
		m : alpus_wb32_tos_t;
		a : alpus_wb32_tom_t;
		b : alpus_wb32_tom_t
	) return alpus_wb32_tom_t is
	begin
		if (adr and mask) = (m.adr and mask) then
			return a;
		else
			return b;
		end if;
	end function;

end;
