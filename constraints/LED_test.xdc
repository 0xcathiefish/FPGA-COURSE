# Clock set

# Sys standared clock with frequency = 50 MHZ
create_clock -period 20.000 -name sys_standard_clk -waveform {0.000 10.000} [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]


# package pin set

# LED port setting
set_property PACKAGE_PIN J14 [get_ports led]
set_property IOSTANDARD  LVCMOS33 [get_ports led]

# rst port setting
set_property PACKAGE_PIN M15 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]













