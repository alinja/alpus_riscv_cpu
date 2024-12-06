create_clock -name "clk" -period 8.000ns [get_ports {clk}]

derive_pll_clocks -create_base_clocks

derive_clock_uncertainty

set_false_path -from {alpus_resetsync:rstsync|rst_i}