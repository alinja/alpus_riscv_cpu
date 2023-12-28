-- alpus_riscv_cpu_example
--
-- Example design and a starting template for a new design with a riscv soft cpu.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.config_pkg.all;
use work.firmware_mem_pkg.all;
use work.alpus_wb32_pkg.all;
use work.alpus_riscv_cpu_pkg.all;

entity alpus_riscv_cpu_example is
port(
	clk : in std_logic;
	rst : in std_logic;

	txd      : out std_logic;
	led      : out std_logic
);
end entity alpus_riscv_cpu_example;

architecture example of alpus_riscv_cpu_example is

	--constant CPU_CHOICE : string := "SERV";
	constant CPU_CHOICE : string := "VEX";
	constant MEM_RTL_AREG : std_logic := CONFIG_MEM_RTL_AREG; -- tune these for successful inferring on different tools
	constant MEM_RTL_AREGI : std_logic := CONFIG_MEM_RTL_AREG;
	signal wb_tos : alpus_wb32_tos_t;
	signal wb_tom : alpus_wb32_tom_t;

	signal irq_timer : std_logic;

	signal mtime : signed(31 downto 0);
	signal mtimecmp : signed(31 downto 0);
	signal reg0 : std_logic_vector(31 downto 0);
	signal reg2 : std_logic_vector(31 downto 0);
	signal reg3 : std_logic_vector(31 downto 0);
	signal acc_ctr : integer range 0 to 63;

	signal rst_ctr : unsigned(3 downto 0) := x"0";
	signal rst_i : std_logic;

begin
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
		clk => clk,
		rst => rst_i,
		wb_tos => wb_tos,
		wb_tom => wb_tom,
		irq_timer => irq_timer
	);

	process(clk)
	begin
		if rising_edge(clk) then
			-- self-reseting example design
			if rst_ctr < 10 then
				rst_i <= '1';
				rst_ctr <= rst_ctr + 1;
			else
				rst_i <= '0';
			end if;
			if HAS_RST = '1' and rst = RST_ACTIVE then
				rst_ctr <= x"0";
			end if;

			-- example register bank with artificially long response times
			-- timer and gpio are required by the baremetal example software
			wb_tom.ack <= '0';
			wb_tom.stall <= '1';
			acc_ctr <= 0;
			if wb_tos.cyc = '1' and wb_tos.stb = '1' and wb_tos.we = '1' then
				case wb_tos.adr(9 downto 2) is
				when x"00" =>
					reg0 <= wb_tos.data;
				when x"01" =>
					mtimecmp <= signed(wb_tos.data);
				when others =>
					null;
				end case;
				if acc_ctr = 7 then
					wb_tom.stall <= '0';
					--wb_tom.ack <= '1'; --quick ack
					acc_ctr <= 0;
				else
					acc_ctr <= acc_ctr + 1;
				end if;
				wb_tom.ack <= not wb_tom.stall;
			end if;
			if wb_tos.cyc = '1' and wb_tos.stb = '1' and wb_tos.we = '0' then
				case wb_tos.adr(9 downto 2) is
				when x"00" =>
					wb_tom.data <= reg0;
				when x"01" =>
					wb_tom.data <= std_logic_vector(mtime);
				when others =>
					wb_tom.data <= x"00000000";
					null;
				end case;
				if acc_ctr = 5 then
					wb_tom.stall <= '0';
					--wb_tom.ack <= '1'; --quick ack
					acc_ctr <= 0;
				else
					acc_ctr <= acc_ctr + 1;
				end if;
				wb_tom.ack <= not wb_tom.stall;
			end if;

			--RiscV requires timer
			mtime <= mtime + 1;
			if mtime - mtimecmp > 0 then
				irq_timer <= '1';
			else
				irq_timer <= '0';
			end if;

			-- reg0 gpio
			if LED_ACTIVE = '1' then
				led <= reg0(0);
			else
				led <= not reg0(0);
			end if;
			txd <= reg0(1);

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