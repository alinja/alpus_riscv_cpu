create_clock -period 82.000 -name clk -waveform {0.000 42.000} [get_ports clk]


set_property PACKAGE_PIN A17 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN L17 [get_ports clk]
set_property PACKAGE_PIN B18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN R3 [get_ports txd]
set_property IOSTANDARD LVCMOS33 [get_ports txd]
set_property PACKAGE_PIN T3 [get_ports rxd]
set_property IOSTANDARD LVCMOS33 [get_ports rxd]





set_false_path -from [get_pins rstsync/rst_i_reg/C]
