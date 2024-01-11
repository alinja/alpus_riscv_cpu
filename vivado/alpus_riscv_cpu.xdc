create_clock -period 6.660 -name clk -waveform {0.000 3.000} [get_ports clk]


set_property PACKAGE_PIN A17 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports led]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
set_property PACKAGE_PIN L17 [get_ports clk]
set_property PACKAGE_PIN B18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property PACKAGE_PIN R3 [get_ports txd]
set_property IOSTANDARD LVCMOS33 [get_ports txd]

connect_debug_port u_ila_0/probe3 [get_nets [list {wb_tom_reg[data]0}]]

connect_debug_port u_ila_0/probe0 [get_nets [list {wb_tom_reg[data][0]} {wb_tom_reg[data][1]}]]
connect_debug_port u_ila_0/probe3 [get_nets [list {wb_tom_reg[ack]}]]
connect_debug_port u_ila_0/probe4 [get_nets [list {wb_tom_reg[ack]0}]]
connect_debug_port u_ila_0/probe6 [get_nets [list {cpu/vex.i/wb_tos_i_reg[stb]__0}]]
connect_debug_port u_ila_0/probe7 [get_nets [list {cpu/vex.i/wb_tos[cyc]}]]
connect_debug_port u_ila_0/probe8 [get_nets [list {wb_tos_i_reg[we]}]]



create_debug_core u_ila_0 ila
set_property ALL_PROBE_SAME_MU true [get_debug_cores u_ila_0]
set_property ALL_PROBE_SAME_MU_CNT 1 [get_debug_cores u_ila_0]
set_property C_ADV_TRIGGER false [get_debug_cores u_ila_0]
set_property C_DATA_DEPTH 1024 [get_debug_cores u_ila_0]
set_property C_EN_STRG_QUAL false [get_debug_cores u_ila_0]
set_property C_INPUT_PIPE_STAGES 0 [get_debug_cores u_ila_0]
set_property C_TRIGIN_EN false [get_debug_cores u_ila_0]
set_property C_TRIGOUT_EN false [get_debug_cores u_ila_0]
set_property port_width 1 [get_debug_ports u_ila_0/clk]
connect_debug_port u_ila_0/clk [get_nets [list clk_IBUF_BUFG]]
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe0]
set_property port_width 4 [get_debug_ports u_ila_0/probe0]
connect_debug_port u_ila_0/probe0 [get_nets [list {wb_tos[sel][0]} {wb_tos[sel][1]} {wb_tos[sel][2]} {wb_tos[sel][3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe1]
set_property port_width 32 [get_debug_ports u_ila_0/probe1]
connect_debug_port u_ila_0/probe1 [get_nets [list {wb_tos[data][0]} {wb_tos[data][1]} {wb_tos[data][2]} {wb_tos[data][3]} {wb_tos[data][4]} {wb_tos[data][5]} {wb_tos[data][6]} {wb_tos[data][7]} {wb_tos[data][8]} {wb_tos[data][9]} {wb_tos[data][10]} {wb_tos[data][11]} {wb_tos[data][12]} {wb_tos[data][13]} {wb_tos[data][14]} {wb_tos[data][15]} {wb_tos[data][16]} {wb_tos[data][17]} {wb_tos[data][18]} {wb_tos[data][19]} {wb_tos[data][20]} {wb_tos[data][21]} {wb_tos[data][22]} {wb_tos[data][23]} {wb_tos[data][24]} {wb_tos[data][25]} {wb_tos[data][26]} {wb_tos[data][27]} {wb_tos[data][28]} {wb_tos[data][29]} {wb_tos[data][30]} {wb_tos[data][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe2]
set_property port_width 32 [get_debug_ports u_ila_0/probe2]
connect_debug_port u_ila_0/probe2 [get_nets [list {wb_tos[adr][0]} {wb_tos[adr][1]} {wb_tos[adr][2]} {wb_tos[adr][3]} {wb_tos[adr][4]} {wb_tos[adr][5]} {wb_tos[adr][6]} {wb_tos[adr][7]} {wb_tos[adr][8]} {wb_tos[adr][9]} {wb_tos[adr][10]} {wb_tos[adr][11]} {wb_tos[adr][12]} {wb_tos[adr][13]} {wb_tos[adr][14]} {wb_tos[adr][15]} {wb_tos[adr][16]} {wb_tos[adr][17]} {wb_tos[adr][18]} {wb_tos[adr][19]} {wb_tos[adr][20]} {wb_tos[adr][21]} {wb_tos[adr][22]} {wb_tos[adr][23]} {wb_tos[adr][24]} {wb_tos[adr][25]} {wb_tos[adr][26]} {wb_tos[adr][27]} {wb_tos[adr][28]} {wb_tos[adr][29]} {wb_tos[adr][30]} {wb_tos[adr][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe3]
set_property port_width 32 [get_debug_ports u_ila_0/probe3]
connect_debug_port u_ila_0/probe3 [get_nets [list {wb_gpio_tos[data][0]} {wb_gpio_tos[data][1]} {wb_gpio_tos[data][2]} {wb_gpio_tos[data][3]} {wb_gpio_tos[data][4]} {wb_gpio_tos[data][5]} {wb_gpio_tos[data][6]} {wb_gpio_tos[data][7]} {wb_gpio_tos[data][8]} {wb_gpio_tos[data][9]} {wb_gpio_tos[data][10]} {wb_gpio_tos[data][11]} {wb_gpio_tos[data][12]} {wb_gpio_tos[data][13]} {wb_gpio_tos[data][14]} {wb_gpio_tos[data][15]} {wb_gpio_tos[data][16]} {wb_gpio_tos[data][17]} {wb_gpio_tos[data][18]} {wb_gpio_tos[data][19]} {wb_gpio_tos[data][20]} {wb_gpio_tos[data][21]} {wb_gpio_tos[data][22]} {wb_gpio_tos[data][23]} {wb_gpio_tos[data][24]} {wb_gpio_tos[data][25]} {wb_gpio_tos[data][26]} {wb_gpio_tos[data][27]} {wb_gpio_tos[data][28]} {wb_gpio_tos[data][29]} {wb_gpio_tos[data][30]} {wb_gpio_tos[data][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe4]
set_property port_width 4 [get_debug_ports u_ila_0/probe4]
connect_debug_port u_ila_0/probe4 [get_nets [list {wb_gpio_tos[sel][0]} {wb_gpio_tos[sel][1]} {wb_gpio_tos[sel][2]} {wb_gpio_tos[sel][3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe5]
set_property port_width 32 [get_debug_ports u_ila_0/probe5]
connect_debug_port u_ila_0/probe5 [get_nets [list {wb_timer_tom[data][0]} {wb_timer_tom[data][1]} {wb_timer_tom[data][2]} {wb_timer_tom[data][3]} {wb_timer_tom[data][4]} {wb_timer_tom[data][5]} {wb_timer_tom[data][6]} {wb_timer_tom[data][7]} {wb_timer_tom[data][8]} {wb_timer_tom[data][9]} {wb_timer_tom[data][10]} {wb_timer_tom[data][11]} {wb_timer_tom[data][12]} {wb_timer_tom[data][13]} {wb_timer_tom[data][14]} {wb_timer_tom[data][15]} {wb_timer_tom[data][16]} {wb_timer_tom[data][17]} {wb_timer_tom[data][18]} {wb_timer_tom[data][19]} {wb_timer_tom[data][20]} {wb_timer_tom[data][21]} {wb_timer_tom[data][22]} {wb_timer_tom[data][23]} {wb_timer_tom[data][24]} {wb_timer_tom[data][25]} {wb_timer_tom[data][26]} {wb_timer_tom[data][27]} {wb_timer_tom[data][28]} {wb_timer_tom[data][29]} {wb_timer_tom[data][30]} {wb_timer_tom[data][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe6]
set_property port_width 32 [get_debug_ports u_ila_0/probe6]
connect_debug_port u_ila_0/probe6 [get_nets [list {wb_timer_tos[adr][0]} {wb_timer_tos[adr][1]} {wb_timer_tos[adr][2]} {wb_timer_tos[adr][3]} {wb_timer_tos[adr][4]} {wb_timer_tos[adr][5]} {wb_timer_tos[adr][6]} {wb_timer_tos[adr][7]} {wb_timer_tos[adr][8]} {wb_timer_tos[adr][9]} {wb_timer_tos[adr][10]} {wb_timer_tos[adr][11]} {wb_timer_tos[adr][12]} {wb_timer_tos[adr][13]} {wb_timer_tos[adr][14]} {wb_timer_tos[adr][15]} {wb_timer_tos[adr][16]} {wb_timer_tos[adr][17]} {wb_timer_tos[adr][18]} {wb_timer_tos[adr][19]} {wb_timer_tos[adr][20]} {wb_timer_tos[adr][21]} {wb_timer_tos[adr][22]} {wb_timer_tos[adr][23]} {wb_timer_tos[adr][24]} {wb_timer_tos[adr][25]} {wb_timer_tos[adr][26]} {wb_timer_tos[adr][27]} {wb_timer_tos[adr][28]} {wb_timer_tos[adr][29]} {wb_timer_tos[adr][30]} {wb_timer_tos[adr][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe7]
set_property port_width 32 [get_debug_ports u_ila_0/probe7]
connect_debug_port u_ila_0/probe7 [get_nets [list {wb_timer_tos[data][0]} {wb_timer_tos[data][1]} {wb_timer_tos[data][2]} {wb_timer_tos[data][3]} {wb_timer_tos[data][4]} {wb_timer_tos[data][5]} {wb_timer_tos[data][6]} {wb_timer_tos[data][7]} {wb_timer_tos[data][8]} {wb_timer_tos[data][9]} {wb_timer_tos[data][10]} {wb_timer_tos[data][11]} {wb_timer_tos[data][12]} {wb_timer_tos[data][13]} {wb_timer_tos[data][14]} {wb_timer_tos[data][15]} {wb_timer_tos[data][16]} {wb_timer_tos[data][17]} {wb_timer_tos[data][18]} {wb_timer_tos[data][19]} {wb_timer_tos[data][20]} {wb_timer_tos[data][21]} {wb_timer_tos[data][22]} {wb_timer_tos[data][23]} {wb_timer_tos[data][24]} {wb_timer_tos[data][25]} {wb_timer_tos[data][26]} {wb_timer_tos[data][27]} {wb_timer_tos[data][28]} {wb_timer_tos[data][29]} {wb_timer_tos[data][30]} {wb_timer_tos[data][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe8]
set_property port_width 4 [get_debug_ports u_ila_0/probe8]
connect_debug_port u_ila_0/probe8 [get_nets [list {wb_timer_tos[sel][0]} {wb_timer_tos[sel][1]} {wb_timer_tos[sel][2]} {wb_timer_tos[sel][3]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe9]
set_property port_width 33 [get_debug_ports u_ila_0/probe9]
connect_debug_port u_ila_0/probe9 [get_nets [list {wb_tom[data][0]} {wb_tom[data][1]} {wb_tom[data][2]} {wb_tom[data][3]} {wb_tom[data][4]} {wb_tom[data][5]} {wb_tom[data][6]} {wb_tom[data][7]} {wb_tom[data][8]} {wb_tom[data][9]} {wb_tom[data][10]} {wb_tom[data][11]} {wb_tom[data][12]} {wb_tom[data][13]} {wb_tom[data][14]} {wb_tom[data][15]} {wb_tom[data][16]} {wb_tom[data][17]} {wb_tom[data][18]} {wb_tom[data][19]} {wb_tom[data][20]} {wb_tom[data][21]} {wb_tom[data][22]} {wb_tom[data][23]} {wb_tom[data][24]} {wb_tom[data][25]} {wb_tom[data][26]} {wb_tom[data][27]} {wb_tom[data][28]} {wb_tom[data][29]} {wb_tom[data][30]} {wb_tom[data][31]} clk_IBUF_BUFG]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe10]
set_property port_width 32 [get_debug_ports u_ila_0/probe10]
connect_debug_port u_ila_0/probe10 [get_nets [list {wb_gpio_tos[adr][0]} {wb_gpio_tos[adr][1]} {wb_gpio_tos[adr][2]} {wb_gpio_tos[adr][3]} {wb_gpio_tos[adr][4]} {wb_gpio_tos[adr][5]} {wb_gpio_tos[adr][6]} {wb_gpio_tos[adr][7]} {wb_gpio_tos[adr][8]} {wb_gpio_tos[adr][9]} {wb_gpio_tos[adr][10]} {wb_gpio_tos[adr][11]} {wb_gpio_tos[adr][12]} {wb_gpio_tos[adr][13]} {wb_gpio_tos[adr][14]} {wb_gpio_tos[adr][15]} {wb_gpio_tos[adr][16]} {wb_gpio_tos[adr][17]} {wb_gpio_tos[adr][18]} {wb_gpio_tos[adr][19]} {wb_gpio_tos[adr][20]} {wb_gpio_tos[adr][21]} {wb_gpio_tos[adr][22]} {wb_gpio_tos[adr][23]} {wb_gpio_tos[adr][24]} {wb_gpio_tos[adr][25]} {wb_gpio_tos[adr][26]} {wb_gpio_tos[adr][27]} {wb_gpio_tos[adr][28]} {wb_gpio_tos[adr][29]} {wb_gpio_tos[adr][30]} {wb_gpio_tos[adr][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe11]
set_property port_width 32 [get_debug_ports u_ila_0/probe11]
connect_debug_port u_ila_0/probe11 [get_nets [list {wb_gpio_tom[data][0]} {wb_gpio_tom[data][1]} {wb_gpio_tom[data][2]} {wb_gpio_tom[data][3]} {wb_gpio_tom[data][4]} {wb_gpio_tom[data][5]} {wb_gpio_tom[data][6]} {wb_gpio_tom[data][7]} {wb_gpio_tom[data][8]} {wb_gpio_tom[data][9]} {wb_gpio_tom[data][10]} {wb_gpio_tom[data][11]} {wb_gpio_tom[data][12]} {wb_gpio_tom[data][13]} {wb_gpio_tom[data][14]} {wb_gpio_tom[data][15]} {wb_gpio_tom[data][16]} {wb_gpio_tom[data][17]} {wb_gpio_tom[data][18]} {wb_gpio_tom[data][19]} {wb_gpio_tom[data][20]} {wb_gpio_tom[data][21]} {wb_gpio_tom[data][22]} {wb_gpio_tom[data][23]} {wb_gpio_tom[data][24]} {wb_gpio_tom[data][25]} {wb_gpio_tom[data][26]} {wb_gpio_tom[data][27]} {wb_gpio_tom[data][28]} {wb_gpio_tom[data][29]} {wb_gpio_tom[data][30]} {wb_gpio_tom[data][31]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe12]
set_property port_width 1 [get_debug_ports u_ila_0/probe12]
connect_debug_port u_ila_0/probe12 [get_nets [list {wb_gpio_tom[ack]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe13]
set_property port_width 1 [get_debug_ports u_ila_0/probe13]
connect_debug_port u_ila_0/probe13 [get_nets [list {wb_gpio_tom[stall]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe14]
set_property port_width 1 [get_debug_ports u_ila_0/probe14]
connect_debug_port u_ila_0/probe14 [get_nets [list {wb_gpio_tos[cyc]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe15]
set_property port_width 1 [get_debug_ports u_ila_0/probe15]
connect_debug_port u_ila_0/probe15 [get_nets [list {wb_gpio_tos[stb]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe16]
set_property port_width 1 [get_debug_ports u_ila_0/probe16]
connect_debug_port u_ila_0/probe16 [get_nets [list {wb_gpio_tos[we]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe17]
set_property port_width 1 [get_debug_ports u_ila_0/probe17]
connect_debug_port u_ila_0/probe17 [get_nets [list {wb_timer_tom[ack]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe18]
set_property port_width 1 [get_debug_ports u_ila_0/probe18]
connect_debug_port u_ila_0/probe18 [get_nets [list {wb_timer_tom[stall]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe19]
set_property port_width 1 [get_debug_ports u_ila_0/probe19]
connect_debug_port u_ila_0/probe19 [get_nets [list {wb_timer_tos[cyc]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe20]
set_property port_width 1 [get_debug_ports u_ila_0/probe20]
connect_debug_port u_ila_0/probe20 [get_nets [list {wb_timer_tos[stb]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe21]
set_property port_width 1 [get_debug_ports u_ila_0/probe21]
connect_debug_port u_ila_0/probe21 [get_nets [list {wb_timer_tos[we]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe22]
set_property port_width 1 [get_debug_ports u_ila_0/probe22]
connect_debug_port u_ila_0/probe22 [get_nets [list {wb_tom[ack]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe23]
set_property port_width 1 [get_debug_ports u_ila_0/probe23]
connect_debug_port u_ila_0/probe23 [get_nets [list {wb_tom[stall]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe24]
set_property port_width 1 [get_debug_ports u_ila_0/probe24]
connect_debug_port u_ila_0/probe24 [get_nets [list {wb_tos[cyc]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe25]
set_property port_width 1 [get_debug_ports u_ila_0/probe25]
connect_debug_port u_ila_0/probe25 [get_nets [list {wb_tos[stb]}]]
create_debug_port u_ila_0 probe
set_property PROBE_TYPE DATA_AND_TRIGGER [get_debug_ports u_ila_0/probe26]
set_property port_width 1 [get_debug_ports u_ila_0/probe26]
connect_debug_port u_ila_0/probe26 [get_nets [list {wb_tos[we]}]]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_IBUF_BUFG]
