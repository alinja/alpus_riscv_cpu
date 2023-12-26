-- alpus_riscv_cpu
--
-- Wrapper and memory environment for various riscv cores
--
-- Todo: separate D/I memories would be easier from inferring point of view
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

package alpus_riscv_cpu_pkg is
    type alpus_riscv_cpu_bytemem_t is array (natural range <>) of std_logic_vector(7 downto 0);

component alpus_riscv_cpu is
generic(
	CPU_CHOICE : string := "SERV";
	COMPRESSED : std_logic := '0';
	MEM_RTL_AREG : std_logic := '0';
	MEM_RTL_AREGI : std_logic := '0'; -- test which one gives better inferring results
	MEM0_INIT : alpus_riscv_cpu_bytemem_t;
	MEM1_INIT : alpus_riscv_cpu_bytemem_t;
	MEM2_INIT : alpus_riscv_cpu_bytemem_t;
	MEM3_INIT : alpus_riscv_cpu_bytemem_t
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : out alpus_wb32_tos_t;
	wb_tom : in alpus_wb32_tom_t;

	irq_timer : in std_logic := '0';
	irq_external : in std_logic := '0';
	irq_software : in std_logic := '0'
);
end component;
end package;


--
-- SERV implementation
--



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;
use work.alpus_riscv_cpu_pkg.all;

package alpus_riscv_cpu_serv_pkg is
component alpus_riscv_cpu_serv is
generic(
	COMPRESSED : std_logic := '0';
	MEM_RTL_AREG : std_logic := '0';
	MEM_RTL_AREGI : std_logic := '0'; -- test which one gives better inferring results
	MEM0_INIT : alpus_riscv_cpu_bytemem_t;
	MEM1_INIT : alpus_riscv_cpu_bytemem_t;
	MEM2_INIT : alpus_riscv_cpu_bytemem_t;
	MEM3_INIT : alpus_riscv_cpu_bytemem_t
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : out alpus_wb32_tos_t;
	wb_tom : in alpus_wb32_tom_t;

	irq_timer : in std_logic := '0';
	irq_external : in std_logic := '0';
	irq_software : in std_logic := '0'
);
end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;
use work.alpus_riscv_cpu_pkg.all;

entity alpus_riscv_cpu_serv is
generic(
	COMPRESSED : std_logic := '0';
	MEM_RTL_AREG : std_logic := '0'; -- test which one gives better inferring results
	MEM_RTL_AREGI : std_logic := '0'; -- test which one gives better inferring results
	MEM0_INIT : alpus_riscv_cpu_bytemem_t;
	MEM1_INIT : alpus_riscv_cpu_bytemem_t;
	MEM2_INIT : alpus_riscv_cpu_bytemem_t;
	MEM3_INIT : alpus_riscv_cpu_bytemem_t
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : out alpus_wb32_tos_t;
	wb_tom : in alpus_wb32_tom_t;

	irq_timer : in std_logic := '0';
	irq_external : in std_logic := '0';
	irq_software : in std_logic := '0'
);
end entity alpus_riscv_cpu_serv;

architecture mix of alpus_riscv_cpu_serv is
component serv_rf_top is
generic (
	RESET_PC : std_logic_vector(31 downto 0) := x"00000000";
	COMPRESSED : std_logic_vector(0 downto 0) := "0";
	ALIGN : std_logic_vector(0 downto 0) := "0";
	MDU : std_logic_vector(0 downto 0) := "0";
	PRE_REGISTER : integer := 1;
	RESET_STRATEGY : string := "MINI";
	WITH_CSR : integer := 1;
	RF_WIDTH : integer := 2;
	RF_L2D : integer := 10
);
port(
	clk : in std_logic;
	i_rst : in std_logic;
	i_timer_irq : in std_logic;

	o_ibus_adr : out std_logic_vector(31 downto 0);
	o_ibus_cyc : out std_logic;
	i_ibus_rdt : in std_logic_vector(31 downto 0);	
	i_ibus_ack : in std_logic;
	
	o_dbus_adr : out std_logic_vector(31 downto 0);
	o_dbus_dat : out std_logic_vector(31 downto 0);
	o_dbus_sel : out std_logic_vector(3 downto 0);
	o_dbus_we  : out std_logic;
	o_dbus_cyc : out std_logic;
	i_dbus_rdt : in std_logic_vector(31 downto 0);
	i_dbus_ack : in std_logic;

	o_ext_rs1    : out std_logic_vector(31 downto 0);
	o_ext_rs2    : out std_logic_vector(31 downto 0);
	o_ext_funct3 : out std_logic_vector(2 downto 0);
	i_ext_rd     : in std_logic_vector(31 downto 0) := x"00000000";
	i_ext_ready : in std_logic := '0';
	o_mdu_valid : out std_logic
);
end component;

	signal wb_tos_i : alpus_wb32_tos_t;
	signal wb_tom_i : alpus_wb32_tom_t;
	
	signal bus_rdata_r : std_logic_vector(31 downto 0);
	signal bus_rvalid_r : std_logic;
	signal periph_access : std_logic;
	signal periph_response : std_logic;

	signal ibus_cyc : std_logic;
	signal ibus_adr : std_logic_vector(31 downto 0);
	signal ibus_adr_i : std_logic_vector(31 downto 0);
	signal ibus_ack : std_logic := '1';
	signal ibus_rdt_i : std_logic_vector(31 downto 0) := x"ffffffff";
	signal ibus_rdt : std_logic_vector(31 downto 0) := x"ffffffff";

	signal dbus_cyc : std_logic;
	signal dbus_rdy : std_logic;
	signal dbus_ack : std_logic;
	signal dbus_ack_i : std_logic;
	signal dbus_we : std_logic;
	signal dbus_adr : std_logic_vector(31 downto 0);
	signal dbus_adr_i : std_logic_vector(31 downto 0);
	signal dbus_dat : std_logic_vector(31 downto 0);
	signal dbus_sel : std_logic_vector(3 downto 0);
	signal dbus_rdt_i0 : std_logic_vector(31 downto 0);
	signal dbus_rdt_i1 : std_logic_vector(31 downto 0);
	signal dbus_rdt : std_logic_vector(31 downto 0);

	function ceil_log2(i : natural) return natural is
		variable pow2 : natural := 1;
		variable exp : natural := 0; 
	begin					
		while pow2 < i loop
			exp := exp + 1;
			pow2 := pow2*2;     
		end loop;
		return exp;
	end function;
	constant MEM_HI : natural := ceil_log2((MEM0_INIT'high+1)*4)-1;
	signal ram0 : alpus_riscv_cpu_bytemem_t(MEM0_INIT'range) := MEM0_INIT;
	signal ram1 : alpus_riscv_cpu_bytemem_t(MEM1_INIT'range) := MEM1_INIT;
	signal ram2 : alpus_riscv_cpu_bytemem_t(MEM2_INIT'range) := MEM2_INIT;
	signal ram3 : alpus_riscv_cpu_bytemem_t(MEM3_INIT'range) := MEM3_INIT;

	attribute ramstyle  : string;
	attribute ramstyle of ram0 : signal is "no_rw_check";
	attribute ramstyle of ram1 : signal is "no_rw_check";
	attribute ramstyle of ram2 : signal is "no_rw_check";
	attribute ramstyle of ram3 : signal is "no_rw_check";

begin
	-- SERV is about 20x slower than vexrisc
	core: serv_rf_top generic map (
		RESET_PC => x"00000000",
		PRE_REGISTER => 0,
		COMPRESSED => (others => COMPRESSED),
		ALIGN => (others => COMPRESSED)
	) port map (
		clk => clk,
		i_rst => rst,
		o_ibus_cyc => ibus_cyc,
		o_ibus_adr => ibus_adr,
		i_ibus_ack => ibus_ack,
		i_ibus_rdt => ibus_rdt,	
		i_timer_irq => irq_timer,

		o_dbus_cyc => dbus_cyc,
		i_dbus_ack => dbus_ack,
		o_dbus_we => dbus_we,
		o_dbus_adr => dbus_adr,
		o_dbus_dat => dbus_dat,
		o_dbus_sel => dbus_sel,
		i_dbus_rdt => dbus_rdt
	);
	
	periph_access <= '1' when dbus_adr(31) = '1' else '0';
	
	dbus_ack <= dbus_ack_i when periph_access = '1' else dbus_rdy;
	g_areg: if MEM_RTL_AREG = '1' generate
		dbus_rdt <= bus_rdata_r when bus_rvalid_r = '1' else dbus_rdt_i1;
		dbus_rdt_i1 <= ram3(to_integer(unsigned(dbus_adr_i(MEM_HI downto 2)))) &
					ram2(to_integer(unsigned(dbus_adr_i(MEM_HI downto 2)))) &
					ram1(to_integer(unsigned(dbus_adr_i(MEM_HI downto 2)))) &
					ram0(to_integer(unsigned(dbus_adr_i(MEM_HI downto 2))));
	end generate;
	g_areg1: if MEM_RTL_AREG = '0' generate
		dbus_rdt <= bus_rdata_r when bus_rvalid_r = '1' else dbus_rdt_i0;
	end generate;
	g_aregi: if MEM_RTL_AREGI = '1' generate
		ibus_rdt <= ram3(to_integer(unsigned(ibus_adr_i(MEM_HI downto 2)))) &
					ram2(to_integer(unsigned(ibus_adr_i(MEM_HI downto 2)))) &
					ram1(to_integer(unsigned(ibus_adr_i(MEM_HI downto 2)))) &
					ram0(to_integer(unsigned(ibus_adr_i(MEM_HI downto 2))));
	end generate;
	g_aregi1: if MEM_RTL_AREGI = '0' generate
		ibus_rdt <= ibus_rdt_i;
	end generate;

	process(clk)
	begin
		if rising_edge(clk) then
			--
			-- Internal memory for D/I bus
			--
			ibus_ack <= ibus_cyc and not ibus_ack;
			ibus_adr_i <= ibus_adr;
			ibus_rdt_i <= ram3(to_integer(unsigned(ibus_adr(MEM_HI downto 2)))) &
						ram2(to_integer(unsigned(ibus_adr(MEM_HI downto 2)))) &
						ram1(to_integer(unsigned(ibus_adr(MEM_HI downto 2)))) &
						ram0(to_integer(unsigned(ibus_adr(MEM_HI downto 2))));
			dbus_rdy <= dbus_cyc and not dbus_adr(31) and not dbus_rdy; 
			if dbus_cyc = '1' and dbus_we = '1' and dbus_rdy = '1' and dbus_adr(31) = '0' then
				if dbus_sel(0) = '1' then
					ram0(to_integer(unsigned(dbus_adr(MEM_HI downto 2)))) <= dbus_dat(7 downto 0);
				end if;
				if dbus_sel(1) = '1' then
					ram1(to_integer(unsigned(dbus_adr(MEM_HI downto 2)))) <= dbus_dat(15 downto 8);
				end if;
				if dbus_sel(2) = '1' then
					ram2(to_integer(unsigned(dbus_adr(MEM_HI downto 2)))) <= dbus_dat(23 downto 16);
				end if;
				if dbus_sel(3) = '1' then
					ram3(to_integer(unsigned(dbus_adr(MEM_HI downto 2)))) <= dbus_dat(31 downto 24);
				end if;
			end if;
			dbus_adr_i <= dbus_adr;
			dbus_rdt_i0       <= ram3(to_integer(unsigned(dbus_adr(MEM_HI downto 2)))) &
								ram2(to_integer(unsigned(dbus_adr(MEM_HI downto 2)))) &
								ram1(to_integer(unsigned(dbus_adr(MEM_HI downto 2)))) &
								ram0(to_integer(unsigned(dbus_adr(MEM_HI downto 2))));

			--
			-- pipelined access to peripheral registers
			--
			bus_rvalid_r <= '0';
			if periph_response = '0' then
				dbus_ack_i <= '0';
				if dbus_adr(31) = '0' then
					dbus_ack_i <= dbus_cyc and dbus_ack and not dbus_we;
				else
					if dbus_cyc = '1' and dbus_ack_i = '0' then
						periph_response <= '1';
						wb_tos_i.adr <= dbus_adr;
						wb_tos_i.data <= dbus_dat;
						wb_tos_i.we <= dbus_we;
						wb_tos_i.cyc <= dbus_cyc and not wb_tom_i.ack;
						wb_tos_i.stb <= dbus_cyc and not wb_tom_i.ack;
					end if;
				end if;
			else
				dbus_ack_i <= wb_tom_i.ack;
				wb_tos_i.we <= dbus_we;
				wb_tos_i.cyc <= dbus_cyc and not wb_tom_i.ack;
				wb_tos_i.stb <= dbus_cyc and not wb_tom_i.ack;
				if wb_tom_i.ack = '1' then
					bus_rdata_r <= wb_tom_i.data;
					bus_rvalid_r <= '1';
					periph_response <= '0';
				end if;
			end if;

			if rst = '1' then
				wb_tos_i <= alpus_wb32_tos_init;
				periph_response <= '0';
			end if;
		end if;
	end process;
	
	wb_tos <= wb_tos_i;
	wb_tom_i <= wb_tom;
end;



--
-- VexRiscV implementation
--



library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;
use work.alpus_riscv_cpu_pkg.all;

package alpus_riscv_cpu_vex_pkg is
component alpus_riscv_cpu_vex is
generic(
	MEM_RTL_AREG : std_logic := '0'; -- test which one gives better inferring results
	MEM_RTL_AREGI : std_logic := '0'; -- test which one gives better inferring results
	MEM0_INIT : alpus_riscv_cpu_bytemem_t;
	MEM1_INIT : alpus_riscv_cpu_bytemem_t;
	MEM2_INIT : alpus_riscv_cpu_bytemem_t;
	MEM3_INIT : alpus_riscv_cpu_bytemem_t
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : out alpus_wb32_tos_t;
	wb_tom : in alpus_wb32_tom_t;

	irq_timer : in std_logic := '0';
	irq_external : in std_logic := '0';
	irq_software : in std_logic := '0'
);
end component;
end package;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;
use work.alpus_riscv_cpu_pkg.all;

entity alpus_riscv_cpu_vex is
generic(
	MEM_RTL_AREG : std_logic := '0'; -- test which one gives better inferring results
	MEM_RTL_AREGI : std_logic := '0'; -- test which one gives better inferring results
	MEM0_INIT : alpus_riscv_cpu_bytemem_t;
	MEM1_INIT : alpus_riscv_cpu_bytemem_t;
	MEM2_INIT : alpus_riscv_cpu_bytemem_t;
	MEM3_INIT : alpus_riscv_cpu_bytemem_t
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : out alpus_wb32_tos_t;
	wb_tom : in alpus_wb32_tom_t;

	irq_timer : in std_logic := '0';
	irq_external : in std_logic := '0';
	irq_software : in std_logic := '0'
);
end entity alpus_riscv_cpu_vex;

architecture mix of alpus_riscv_cpu_vex is
component VexRiscv is
port(
	clk : in std_logic;
	reset : in std_logic;

	iBus_cmd_valid : out std_logic;
	iBus_cmd_ready : in std_logic;
	iBus_cmd_payload_pc : out std_logic_vector(31 downto 0);
	iBus_rsp_valid : in std_logic;
	iBus_rsp_payload_error : in std_logic;
	iBus_rsp_payload_inst : in std_logic_vector(31 downto 0);	
	
	timerInterrupt : in std_logic;
	externalInterrupt : in std_logic;
	softwareInterrupt : in std_logic;

	dBus_cmd_valid : out std_logic;
    dBus_cmd_ready : in std_logic;
    dBus_cmd_payload_wr : out std_logic;
    dBus_cmd_payload_address : out std_logic_vector(31 downto 0);
    dBus_cmd_payload_data : out std_logic_vector(31 downto 0);
    dBus_cmd_payload_size : out std_logic_vector(1 downto 0);
    dBus_rsp_ready : in std_logic;
	dBus_rsp_error : in std_logic;
	dBus_rsp_data : in std_logic_vector(31 downto 0)
);
end component;

	function we_from_bus(addr : std_logic_vector(31 downto 0);
	                     size : std_logic_vector(1 downto 0) ) return std_logic_vector is
		variable we : std_logic_vector(3 downto 0);
	begin
		if size = "00" then
			if addr(1 downto 0) = "00" then
				we := "0001";
			elsif addr(1 downto 0) = "01" then
				we := "0010";
			elsif addr(1 downto 0) = "10" then
				we := "0100";
			else
				we := "1000";
			end if;
		elsif size = "01" then
			if addr(1) = '0' then
				we := "0011";
			else
				we := "1100";
			end if;
		else
			we := "1111";
		end if;
		return we;
	end function;

	signal wb_tos_i : alpus_wb32_tos_t;
	signal wb_tom_i : alpus_wb32_tom_t;
	
	signal bus_rdata_i : std_logic_vector(31 downto 0);
	signal bus_rvalid_i : std_logic;

	signal bus_rdata_r : std_logic_vector(31 downto 0);
	signal bus_rvalid_r : std_logic;
	signal periph_access : std_logic;
	signal periph_response : std_logic;

	signal iBus_cmd_valid : std_logic;
	signal iBus_cmd_ready : std_logic;
	signal iBus_cmd_payload_pc : std_logic_vector(31 downto 0);
	signal iBus_cmd_payload_pc_i : std_logic_vector(31 downto 0);
	signal iBus_rsp_valid : std_logic := '1';
	signal iBus_rsp_payload_inst : std_logic_vector(31 downto 0) := x"ffffffff";
	signal iBus_rsp_payload_inst_i : std_logic_vector(31 downto 0) := x"ffffffff";

	signal dBus_cmd_valid : std_logic;
	signal dBus_cmd_valid_i : std_logic;
	signal dBus_cmd_ready : std_logic;
	signal dBus_cmd_payload_wr : std_logic;
	signal dBus_cmd_payload_address : std_logic_vector(31 downto 0);
	signal dBus_cmd_payload_address_i : std_logic_vector(31 downto 0);
	signal dBus_cmd_payload_data : std_logic_vector(31 downto 0);
	signal dBus_cmd_payload_size : std_logic_vector(1 downto 0);
	signal dBus_rsp_ready : std_logic;
	signal dBus_rsp_data_i0 : std_logic_vector(31 downto 0);
	signal dBus_rsp_data_i1 : std_logic_vector(31 downto 0);
	signal dBus_rsp_data : std_logic_vector(31 downto 0);

	function ceil_log2(i : natural) return natural is
		variable pow2 : natural := 1;
		variable exp : natural := 0; 
	begin					
		while pow2 < i loop
			exp := exp + 1;
			pow2 := pow2*2;     
		end loop;
		return exp;
	end function;
	constant MEM_HI : natural := ceil_log2((MEM0_INIT'high+1)*4)-1;
	signal ram0 : alpus_riscv_cpu_bytemem_t(MEM0_INIT'range) := MEM0_INIT;
	signal ram1 : alpus_riscv_cpu_bytemem_t(MEM1_INIT'range) := MEM1_INIT;
	signal ram2 : alpus_riscv_cpu_bytemem_t(MEM2_INIT'range) := MEM2_INIT;
	signal ram3 : alpus_riscv_cpu_bytemem_t(MEM3_INIT'range) := MEM3_INIT;

	attribute ramstyle  : string;
	attribute ramstyle of ram0 : signal is "no_rw_check";
	attribute ramstyle of ram1 : signal is "no_rw_check";
	attribute ramstyle of ram2 : signal is "no_rw_check";
	attribute ramstyle of ram3 : signal is "no_rw_check";
	
	signal rst_i : std_logic;

begin
	rst_i <= rst;

	-- base version, add STATIC branch and mem bypass for 30% faster
	vex: VexRiscv port map (
		clk => clk,
		reset => rst_i,
		iBus_cmd_valid => iBus_cmd_valid,
		iBus_cmd_ready => iBus_cmd_ready,
		iBus_cmd_payload_pc => iBus_cmd_payload_pc,
		iBus_rsp_valid => iBus_rsp_valid,
		iBus_rsp_payload_error => '0',
		iBus_rsp_payload_inst => iBus_rsp_payload_inst,	
		timerInterrupt => irq_timer,
		externalInterrupt => irq_external,
		softwareInterrupt => irq_software,
		dBus_cmd_valid => dBus_cmd_valid,
		dBus_cmd_ready => dBus_cmd_ready,
		dBus_cmd_payload_wr => dBus_cmd_payload_wr,
		dBus_cmd_payload_address => dBus_cmd_payload_address,
		dBus_cmd_payload_data => dBus_cmd_payload_data,
		dBus_cmd_payload_size => dBus_cmd_payload_size,
		dBus_rsp_ready => dBus_rsp_ready,
		dBus_rsp_error => '0',
		dBus_rsp_data => dBus_rsp_data
	);
	periph_access <= '1' when dBus_cmd_payload_address(31) = '1' else '0';
	
	dBus_cmd_ready <= wb_tom_i.ack when periph_access = '1' else dBus_cmd_valid;

	g_areg: if MEM_RTL_AREG = '1' generate
		dBus_rsp_data <= bus_rdata_r when bus_rvalid_r = '1' else dBus_rsp_data_i1;
		dBus_rsp_data_i1       <= ram3(to_integer(unsigned(dBus_cmd_payload_address_i(MEM_HI downto 2)))) &
								 ram2(to_integer(unsigned(dBus_cmd_payload_address_i(MEM_HI downto 2)))) &
								 ram1(to_integer(unsigned(dBus_cmd_payload_address_i(MEM_HI downto 2)))) &
								 ram0(to_integer(unsigned(dBus_cmd_payload_address_i(MEM_HI downto 2))));
	end generate;
	g_areg2: if MEM_RTL_AREG = '0' generate
		dBus_rsp_data <= bus_rdata_r when bus_rvalid_r = '1' else dBus_rsp_data_i0;
	end generate;
	g_aregi: if MEM_RTL_AREGI = '1' generate
		iBus_rsp_payload_inst <= ram3(to_integer(unsigned(iBus_cmd_payload_pc_i(MEM_HI downto 2)))) &
								ram2(to_integer(unsigned(iBus_cmd_payload_pc_i(MEM_HI downto 2)))) &
								ram1(to_integer(unsigned(iBus_cmd_payload_pc_i(MEM_HI downto 2)))) &
								ram0(to_integer(unsigned(iBus_cmd_payload_pc_i(MEM_HI downto 2))));
	end generate;
	g_aregi2: if MEM_RTL_AREGI = '0' generate
		iBus_rsp_payload_inst <= iBus_rsp_payload_inst_i;
	end generate;

	process(clk)
	begin
		if rising_edge(clk) then
			--
			-- Internal memory for D/I bus
			--
			iBus_cmd_ready <= iBus_cmd_valid and not iBus_cmd_ready;
			iBus_rsp_valid <= iBus_cmd_valid and not iBus_rsp_valid;
			iBus_cmd_payload_pc_i <= iBus_cmd_payload_pc;
			iBus_rsp_payload_inst_i <= ram3(to_integer(unsigned(iBus_cmd_payload_pc(MEM_HI downto 2)))) &
									ram2(to_integer(unsigned(iBus_cmd_payload_pc(MEM_HI downto 2)))) &
									ram1(to_integer(unsigned(iBus_cmd_payload_pc(MEM_HI downto 2)))) &
									ram0(to_integer(unsigned(iBus_cmd_payload_pc(MEM_HI downto 2))));

			if dBus_cmd_valid = '1' and dBus_cmd_payload_wr = '1' and dBus_cmd_payload_address(31) = '0' then
				if we_from_bus(dBus_cmd_payload_address, dBus_cmd_payload_size)(0) = '1' then
					ram0(to_integer(unsigned(dBus_cmd_payload_address(MEM_HI downto 2)))) <= dBus_cmd_payload_data(7 downto 0);
				end if;
				if we_from_bus(dBus_cmd_payload_address, dBus_cmd_payload_size)(1) = '1' then
					ram1(to_integer(unsigned(dBus_cmd_payload_address(MEM_HI downto 2)))) <= dBus_cmd_payload_data(15 downto 8);
				end if;
				if we_from_bus(dBus_cmd_payload_address, dBus_cmd_payload_size)(2) = '1' then
					ram2(to_integer(unsigned(dBus_cmd_payload_address(MEM_HI downto 2)))) <= dBus_cmd_payload_data(23 downto 16);
				end if;
				if we_from_bus(dBus_cmd_payload_address, dBus_cmd_payload_size)(3) = '1' then
					ram3(to_integer(unsigned(dBus_cmd_payload_address(MEM_HI downto 2)))) <= dBus_cmd_payload_data(31 downto 24);
				end if;
			end if;
			dBus_cmd_payload_address_i <= dBus_cmd_payload_address;
			dBus_rsp_data_i0       <= ram3(to_integer(unsigned(dBus_cmd_payload_address(MEM_HI downto 2)))) &
									 ram2(to_integer(unsigned(dBus_cmd_payload_address(MEM_HI downto 2)))) &
									 ram1(to_integer(unsigned(dBus_cmd_payload_address(MEM_HI downto 2)))) &
									 ram0(to_integer(unsigned(dBus_cmd_payload_address(MEM_HI downto 2))));
			--
			-- pipelined access to peripheral registers
			--
			bus_rvalid_r <= '0';
			if periph_response = '0' then
				dBus_rsp_ready <= '0';
				if dBus_cmd_payload_address(31) = '0' then
					dBus_rsp_ready <= dBus_cmd_valid and not dBus_cmd_payload_wr;
				else
					if dBus_cmd_valid = '1' then
						if dBus_cmd_payload_wr = '0' then
							periph_response <= '1';
						end if;
						wb_tos_i.adr <= dBus_cmd_payload_address;
						wb_tos_i.data <= dBus_cmd_payload_data;
						wb_tos_i.we <= dBus_cmd_payload_wr;
						wb_tos_i.cyc <= dBus_cmd_valid and not wb_tom_i.ack;
						wb_tos_i.stb <= dBus_cmd_valid and not wb_tom_i.ack;
					end if;
				end if;
			else
				dBus_rsp_ready <= wb_tom_i.ack;
				wb_tos_i.we <= dBus_cmd_payload_wr;
				wb_tos_i.cyc <= dBus_cmd_valid and not wb_tom_i.ack;
				wb_tos_i.stb <= dBus_cmd_valid and not wb_tom_i.ack;
				if wb_tom_i.ack = '1' then
					bus_rdata_r <= wb_tom_i.data;
					bus_rvalid_r <= '1';
					periph_response <= '0';
				end if;
			end if;

			if rst_i = '1' then
				wb_tos_i <= alpus_wb32_tos_init;
				periph_response <= '0';
			end if;
		end if;
	end process;
	
	wb_tos <= wb_tos_i;
	wb_tom_i <= wb_tom;
end;




--
-- TOP level implementation
--





library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;
use work.alpus_riscv_cpu_pkg.all;
use work.alpus_riscv_cpu_serv_pkg.all;
use work.alpus_riscv_cpu_vex_pkg.all;

entity alpus_riscv_cpu is
generic(
	CPU_CHOICE : string := "SERV";
	COMPRESSED : std_logic := '0';
	MEM_RTL_AREG : std_logic := '0'; -- test which one gives better inferring results
	MEM_RTL_AREGI : std_logic := '0'; -- test which one gives better inferring results
	MEM0_INIT : alpus_riscv_cpu_bytemem_t;
	MEM1_INIT : alpus_riscv_cpu_bytemem_t;
	MEM2_INIT : alpus_riscv_cpu_bytemem_t;
	MEM3_INIT : alpus_riscv_cpu_bytemem_t
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : out alpus_wb32_tos_t;
	wb_tom : in alpus_wb32_tom_t;

	irq_timer : in std_logic := '0';
	irq_external : in std_logic := '0';
	irq_software : in std_logic := '0'
);
end entity alpus_riscv_cpu;

architecture top of alpus_riscv_cpu is

begin
	serv: if CPU_CHOICE = "SERV" generate
		i: alpus_riscv_cpu_serv generic map (
			COMPRESSED => '0',
			MEM_RTL_AREG => MEM_RTL_AREG,
			MEM_RTL_AREGI => MEM_RTL_AREGI,
			MEM0_INIT => MEM0_INIT,
			MEM1_INIT => MEM1_INIT,
			MEM2_INIT => MEM2_INIT,
			MEM3_INIT => MEM3_INIT
		) port map (
			clk => clk,
			rst => rst,
			wb_tos => wb_tos,
			wb_tom => wb_tom,
			irq_timer => irq_timer
		);
	end generate;

	vex: if CPU_CHOICE = "VEX" generate
		i: alpus_riscv_cpu_vex generic map (
			MEM_RTL_AREG => MEM_RTL_AREG,
			MEM_RTL_AREGI => MEM_RTL_AREGI,
			MEM0_INIT => MEM0_INIT,
			MEM1_INIT => MEM1_INIT,
			MEM2_INIT => MEM2_INIT,
			MEM3_INIT => MEM3_INIT
		) port map (
			clk => clk,
			rst => rst,
			wb_tos => wb_tos,
			wb_tom => wb_tom,
			irq_timer => irq_timer
		);
	end generate;

end;

