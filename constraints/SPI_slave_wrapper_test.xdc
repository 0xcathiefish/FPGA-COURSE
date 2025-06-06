# Version 1.0

# SPI Use J21 

# J 21

# Pin assignment table:
# 1     GND     2   +5V
# 3     M18     4   M17
# 5	    K19	    6	J19
# 7	    B19	    8	A20
# 9	    B20	    10	C20
# 11	G19	    12	G20
# 13	M19	    14	M20
# 15	D20	    16	D19  clk
# 17	L20	    18	L19
# 19	F16	    20	F17
# 21	H20	    22	J20
# 23	G18	    24	G17
# 25	H17	    26	H16
# 27	G15	    28	H15
# 29	K18	    30	K17
# 31	J16	    32	K16
# 33	N16	    34	N15
# 35	L15	    36	L14
# 37	GND	    38	GND
# 39	+3.3V	40	+3.3V


set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets spi_clk_IBUF]

# Sys clock

create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports sys_clk]
set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]

# spi clock definition

create_clock -period 1000.000 -name spi_clk [get_ports spi_clk]

# Input clock delay

set_input_delay -clock spi_clk -max 10.000 [get_ports w_spi_mosi]
set_input_delay -clock spi_clk -min 2.000  [get_ports w_spi_mosi]

set_input_delay -clock spi_clk -max 5.000  [get_ports w_spi_ss_n0]
set_input_delay -clock spi_clk -min 1.000  [get_ports w_spi_ss_n0]


set_clock_groups -asynchronous -group [get_clocks spi_clk] -group [get_clocks sys_clk]






# pin xdc

set_property PACKAGE_PIN C20 [get_ports w_spi_ss_n0 ]
set_property PACKAGE_PIN G20 [get_ports w_spi_mosi  ]
set_property PACKAGE_PIN M20 [get_ports w_spi_miso  ]
set_property PACKAGE_PIN D19 [get_ports spi_clk     ]
set_property PACKAGE_PIN A20 [get_ports w_test_led  ]

set_property IOSTANDARD LVCMOS33 [get_ports w_spi_ss_n0 ]
set_property IOSTANDARD LVCMOS33 [get_ports w_spi_mosi  ]
set_property IOSTANDARD LVCMOS33 [get_ports w_spi_miso  ]
set_property IOSTANDARD LVCMOS33 [get_ports spi_clk     ]
set_property IOSTANDARD LVCMOS33 [get_ports w_test_led  ]

set_property PULLTYPE PULLUP    [get_ports w_spi_ss_n0]
set_property PULLTYPE PULLDOWN  [get_ports w_spi_mosi]
set_property PULLTYPE PULLDOWN  [get_ports w_spi_miso]
set_property PULLTYPE PULLDOWN  [get_ports spi_clk]
set_property PULLTYPE PULLDOWN  [get_ports w_test_led]


