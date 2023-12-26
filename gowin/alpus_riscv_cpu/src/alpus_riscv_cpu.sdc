//Copyright (C)2014-2023 GOWIN Semiconductor Corporation.
//All rights reserved.
//File Title: Timing Constraints file
//GOWIN Version: 1.9.9 Beta-4 Education
//Created Time: 2023-12-20 20:08:23
create_clock -name clk -period 37 -waveform {0 18.5} [get_ports {clk}]
