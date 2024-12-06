-- alpus_riscv_cpu_example
--
-- Example design and a starting template for a new design with a riscv soft cpu.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.alpus_pll_pkg.all;
use work.alpus_resetsync_pkg.all;
use work.firmware_mem_pkg.all;
use work.alpus_wb32_pkg.all;
use work.alpus_riscv_cpu_pkg.all;
use work.alpus_wb_gpio_pkg.all;

entity alpus_riscv_cpu_example is
port(
	clk : in std_logic;
	rst : in std_logic;

	txd      : inout std_logic;
	rxd      : inout std_logic;
	led      : inout std_logic
);
end entity alpus_riscv_cpu_example;

architecture example of alpus_riscv_cpu_example is

	--constant CPU_CHOICE : string := "SERV";
	constant CPU_CHOICE : string := "VEX";
	constant MEM_RTL_AREG : std_logic := CONFIG_MEM_RTL_AREG; -- tune these for successful inferring on different tools
	constant MEM_RTL_AREGI : std_logic := CONFIG_MEM_RTL_AREG;
	signal wb_tos : alpus_wb32_tos_t;
	signal wb_tom : alpus_wb32_tom_t;

	signal wb_gpio_tos : alpus_wb32_tos_t;
	signal wb_gpio_tom : alpus_wb32_tom_t;
	signal wb_timer_tos : alpus_wb32_tos_t := alpus_wb32_tos_init;
	signal wb_timer_tom : alpus_wb32_tom_t := alpus_wb32_tom_init;
	attribute mark_debug : string;
	attribute mark_debug of wb_tos   : signal is "true";
	attribute mark_debug of wb_tom   : signal is "true";
	attribute mark_debug of wb_gpio_tos   : signal is "true";
	attribute mark_debug of wb_gpio_tom   : signal is "true";
	attribute mark_debug of wb_timer_tos   : signal is "true";
	attribute mark_debug of wb_timer_tom   : signal is "true";

	signal irq_timer : std_logic;
	signal irq_external : std_logic;

	signal gpio : std_logic_vector(1 downto 0);

	signal mtime : signed(31 downto 0);
	signal mtimecmp : signed(31 downto 0);
	signal reg0 : std_logic_vector(31 downto 0);
	signal reg2 : std_logic_vector(31 downto 0);
	signal reg3 : std_logic_vector(31 downto 0);
	signal acc_ctr : integer range 0 to 63;

	signal rst_ctr : unsigned(3 downto 0) := x"0";
	signal rst_ah : std_logic;
	signal locked : std_logic;
	signal rst_i : std_logic;
	signal clk_i : std_logic;

begin
	-- Convert to active high reset if available
	rst_ah <= rst xor not RST_ACTIVE when HAS_RST = '1' else '0';

	-- Unified interface for arhcitecure specific instantiations
	pll: alpus_pll generic map (
		ARCH => alpus_pll_arch_synth_or_sim(PLL_ARCH, "SIMULA"),
		IN_FREQ_MHZ => PLL_FREQ_MHZ,
		OUT0_DIV => PLL_OUT0_DIV,
		IN_DIV => PLL_IN_DIV,
		IN_MUL => PLL_IN_MUL
	) port map (
		in_clk => clk,
		in_rst => rst_ah,
		out_clk0 => clk_i,
		out_locked => locked
	);
	-- Reset synchronizer
	rstsync: alpus_resetsync generic map (
		NUM_CLOCKS => 1
	) port map (
		slow_clk => clk,
		arst => rst_ah,
		locked => locked,
		clk(0) => clk_i,
		rst(0) => rst_i
	);

	-- Instantiate the alpus_riscv_cpu core
	cpu: alpus_riscv_cpu generic map (
		CPU_CHOICE => CPU_CHOICE,
		COMPRESSED => '0',
		MEM_RTL_AREG => MEM_RTL_AREG,
		MEM_RTL_AREGI => MEM_RTL_AREGI,
		MEM0_INIT => firmware_mem_b0,
		MEM1_INIT => firmware_mem_b1,
		MEM2_INIT => firmware_mem_b2,
		MEM3_INIT => firmware_mem_b3
	) port map (
		clk => clk_i,
		rst => rst_i,
		wb_tos => wb_tos,
		wb_tom => wb_tom,
		irq_timer => irq_timer
	);

	-- wishbone slave address map
	wb_timer_tos <= alpus_wb32_slave_select_tos(x"80000000", x"f0000000", wb_tos);
	wb_gpio_tos <= alpus_wb32_slave_select_tos(x"c0000000", x"f0000000", wb_tos);
	wb_tom  <= alpus_wb32_slave_select_tom(x"80000000", x"f0000000", wb_tos, wb_timer_tom, wb_gpio_tom);

	io : alpus_wb_gpio generic map (
		PINS => 2,
		NO_INPUT => '0'
	) port map (
		clk => clk_i,
		rst => rst_i,
		wb_tos => wb_gpio_tos,
		wb_tom => wb_gpio_tom,
		gpio => gpio,
		irq => irq_external
	);

	led <= gpio(0);
	txd <= gpio(1);

	process(clk_i)
	begin
		if rising_edge(clk_i) then

			-- example register bank with artificially long response times
			-- timer and gpio are required by the baremetal example software
			wb_timer_tom.ack <= '0';
			wb_timer_tom.stall <= '1';
			acc_ctr <= 0;
			if wb_timer_tos.cyc = '1' and wb_timer_tos.stb = '1' and wb_timer_tos.we = '1' then
				case wb_timer_tos.adr(9 downto 2) is
				when x"00" =>
					reg0 <= wb_timer_tos.data;
				when x"01" =>
					mtimecmp <= signed(wb_timer_tos.data);
				when others =>
					null;
				end case;
				if acc_ctr = 7 then
					wb_timer_tom.stall <= '0';
					--wb_timer_tom.ack <= '1'; --quick ack
					acc_ctr <= 0;
				else
					acc_ctr <= acc_ctr + 1;
				end if;
				wb_timer_tom.ack <= not wb_timer_tom.stall;
			end if;
			if wb_timer_tos.cyc = '1' and wb_timer_tos.stb = '1' and wb_timer_tos.we = '0' then
				case wb_timer_tos.adr(9 downto 2) is
				when x"00" =>
					wb_timer_tom.data <= reg0;
				when x"01" =>
					wb_timer_tom.data <= std_logic_vector(mtime);
				when others =>
					wb_timer_tom.data <= x"00000000";
					null;
				end case;
				if acc_ctr = 5 then
					wb_timer_tom.stall <= '0';
					--wb_timer_tom.ack <= '1'; --quick ack
					acc_ctr <= 0;
				else
					acc_ctr <= acc_ctr + 1;
				end if;
				wb_timer_tom.ack <= not wb_timer_tom.stall;
			end if;
			reg0(31) <= not LED_ACTIVE; -- bit31 tells sw to invert led

			--RiscV requires timer
			mtime <= mtime + 1;
			if mtime - mtimecmp > 0 then
				irq_timer <= '1';
			else
				irq_timer <= '0';
			end if;

			if rst_i = '1' then
				acc_ctr <= 0;
				irq_timer <= '0';
				mtime <= x"00000000";
				mtimecmp <= x"00000000";
				reg0 <= x"00000002";
			end if;
		end if;
	end process;

end;