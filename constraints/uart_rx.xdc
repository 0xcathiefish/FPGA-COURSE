
# clk

create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports i_clk]
set_property PACKAGE_PIN U18 [get_ports i_clk]
set_property IOSTANDARD LVCMOS33 [get_ports i_clk]


set_property PACKAGE_PIN M15 [get_ports i_enable]
set_property IOSTANDARD LVCMOS33 [get_ports i_enable]



set_property PACKAGE_PIN C20 [get_ports i_din]
set_property IOSTANDARD LVCMOS33 [get_ports i_din]




set_property PACKAGE_PIN A20 [get_ports w_test_led]
set_property IOSTANDARD LVCMOS33 [get_ports w_test_led]
set_property PULLTYPE PULLDOWN [get_ports w_test_led]

