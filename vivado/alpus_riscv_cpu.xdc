create_clock -period 6.660 -name clk -waveform {0.000 3.000} [get_ports clk]


set_property PACKAGE_PIN A17 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN L17 [get_ports clk]
set_property PACKAGE_PIN B18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN R3 [get_ports txd]
set_property IOSTANDARD LVCMOS33 [get_ports txd]
