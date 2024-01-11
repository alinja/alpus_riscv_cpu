-- alpus_riscv_cpu_example_tb tesbench

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alpus_riscv_cpu_example_tb is
end entity alpus_riscv_cpu_example_tb;

architecture tb of alpus_riscv_cpu_example_tb is
	component alpus_riscv_cpu_example is
	port(
		clk : in std_logic;
		rst : in std_logic;

		txd      : inout std_logic;
		led      : inout std_logic
	);
	end component;

	constant CLK_PERIOD : time := 10.0 ns;
	
	signal clk : std_logic := '0';
	signal rst : std_logic := '1';
	
begin

	clk <= not clk after CLK_PERIOD /2;
	rst <= '0' after 500 ns;
	
	dut: alpus_riscv_cpu_example port map (
		clk => clk,
		rst => rst,
		led => open	);

end;