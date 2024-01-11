-- alpus_wb_gpio - generic full-featured gpio

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

package alpus_wb_gpio_pkg is
component alpus_wb_gpio is
generic(
	PINS : integer := 32;
	NO_IRQ : std_logic := '0';
	NO_OUTPUT : std_logic := '0';
	NO_INPUT : std_logic := '0'
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : in alpus_wb32_tos_t;
	wb_tom : out alpus_wb32_tom_t;

	gpio : inout std_logic_vector(PINS-1 downto 0);

	irq : out std_logic;
	irq_level : out std_logic
);
end component;
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.alpus_wb32_pkg.all;

entity alpus_wb_gpio is
generic(
	PINS : integer := 32;
	NO_IRQ : std_logic := '0';
	NO_OUTPUT : std_logic := '0';
	NO_INPUT : std_logic := '0'
);
port(
	clk : in std_logic;
	rst : in std_logic;

	wb_tos : in alpus_wb32_tos_t;
	wb_tom : out alpus_wb32_tom_t;

	gpio : inout std_logic_vector(PINS-1 downto 0);

	irq : out std_logic;
	irq_level : out std_logic
);
end entity alpus_wb_gpio;

architecture rtl of alpus_wb_gpio is

	signal addr : std_logic_vector(7 downto 0);
	
	signal reg_gpio_out : std_logic_vector(PINS-1 downto 0);
	signal reg_gpio_oen : std_logic_vector(PINS-1 downto 0);
	signal reg_irq_en : std_logic_vector(PINS-1 downto 0);
	signal reg_irq_flag : std_logic_vector(PINS-1 downto 0);
	--signal reg_irq_edgemode : std_logic_vector(PINS-1 downto 0);
	signal acc_ctr : integer range 0 to 63;
	
	signal gpio_r : std_logic_vector(PINS-1 downto 0);
	signal gpio_rr : std_logic_vector(PINS-1 downto 0);
	signal gpio_rrr : std_logic_vector(PINS-1 downto 0);

begin
	addr <= "000" & wb_tos.adr(4 downto 2) & "00";
	process(clk)
		variable PIN_CHANGE_IRQ : std_logic;
		variable FLAG_ACTIVE_IRQ : std_logic;
	begin
		if rising_edge(clk) then

			wb_tom.ack <= '0';
			wb_tom.stall <= '0';
			acc_ctr <= 0;
			if wb_tos.cyc = '1' and wb_tos.stb = '1' and wb_tos.we = '1' then
				case addr is
				when x"00" =>
					reg_gpio_out <= wb_tos.data(gpio'range);
				when x"04" =>
					reg_gpio_out <= reg_gpio_out or wb_tos.data(gpio'range);
				when x"08" =>
					reg_gpio_out <= reg_gpio_out and not wb_tos.data(gpio'range);
				when x"10" =>
					reg_gpio_oen <= wb_tos.data(gpio'range);
				when x"14" =>
					reg_irq_en <= wb_tos.data(gpio'range);
				when x"18" =>
					reg_irq_flag <= reg_irq_flag and not wb_tos.data(gpio'range); --wr 1 clear
				when others =>
					null;
				end case;
				if acc_ctr = 1 then
					wb_tom.ack <= '1';
					wb_tom.stall <= '0';
					acc_ctr <= 0;
				else
					acc_ctr <= acc_ctr + 1;
				end if;
				wb_tom.ack <= '1';
			end if;
			if wb_tos.cyc = '1' and wb_tos.stb = '1' and wb_tos.we = '0' then
				wb_tom.data <= (others => '0');
				case addr is
				when x"00" =>
					wb_tom.data(gpio'range) <= reg_gpio_out;
				when x"04" =>
					wb_tom.data(gpio'range) <= (others => '0');
				when x"08" =>
					wb_tom.data(gpio'range) <= (others => '0');
				when x"0c" =>
					wb_tom.data(gpio'range) <= gpio_rr;
				when x"10" =>
					wb_tom.data(gpio'range) <= reg_gpio_oen;
				when x"14" =>
					wb_tom.data(gpio'range) <= reg_irq_en;
				when x"18" =>
					wb_tom.data(gpio'range) <= reg_irq_flag;
				when others =>
					wb_tom.data(gpio'range) <= (others => '0');
					null;
				end case;
				if acc_ctr = 1 then
					wb_tom.ack <= '1';
					wb_tom.stall <= '0';
					acc_ctr <= 0;
				else
					acc_ctr <= acc_ctr + 1;
				end if;
				wb_tom.ack <= '1';
			end if;
			
			if NO_OUTPUT = '0' then
				for i in gpio'range loop
					if reg_gpio_oen(i) = '1' then
						gpio(i) <= reg_gpio_out(i);
					else
						gpio(i) <= 'Z';
					end if;
				end loop;
			end if;

			gpio_r <= gpio;
			gpio_rr <= gpio_r;
			gpio_rrr <= gpio_rr;
			
			PIN_CHANGE_IRQ := '0';
			FLAG_ACTIVE_IRQ := '0';
			for i in gpio_rr'range loop
				if reg_irq_flag(i) = '1' then
					FLAG_ACTIVE_IRQ := '1';
				end if;
				if gpio_rrr(i) /= gpio_rr(i) and reg_irq_en(i) = '1' then
					reg_irq_flag(i) <= '1';
					PIN_CHANGE_IRQ := '1';
					FLAG_ACTIVE_IRQ := '1';
				end if;
			end loop;			
			irq <= PIN_CHANGE_IRQ;
			irq_level <= FLAG_ACTIVE_IRQ;
		
			if rst = '1' then
				acc_ctr <= 0;
				irq <= '0';
				if NO_OUTPUT = '0' then
					gpio <= (others => 'Z');
				end if;
				reg_gpio_out <= (others => '0');
				reg_gpio_oen <= (others => '0');
				reg_irq_en <= (others => '0');
				reg_irq_flag <= (others => '0');
				--reg_irq_edgemode <= (others => '0');
			end if;
			if NO_INPUT = '1' then
				gpio_rr <= (others => '0');
				reg_gpio_oen <= (others => '1');
				reg_irq_en <= (others => '0');
				reg_irq_flag <= (others => '0');
			end if;
			if NO_IRQ = '1' then
				reg_irq_en <= (others => '0');
				reg_irq_flag <= (others => '0');
			end if;
			if NO_OUTPUT = '1' then
				reg_gpio_out <= (others => '0');
				reg_gpio_oen <= (others => '0');
			end if;
		end if;
	end process;

end;