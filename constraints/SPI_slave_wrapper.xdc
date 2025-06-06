# Version 1.1

# Clock set

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets spi_clk_IBUF]

# sys clk

create_clock -period 20.000 -name sys_clk -waveform {0.000 10.000} [get_ports sys_clk]
set_property PACKAGE_PIN U18 [get_ports sys_clk]
set_property IOSTANDARD LVCMOS33 [get_ports sys_clk]


# Set to 1M Hz
create_clock -period 1000.000 -name spi_clk [get_ports spi_clk]


# SPI clock delay logic

set_input_delay -clock spi_clk -max 10.000 [get_ports w_spi_mosi]
set_input_delay -clock spi_clk -min 2.000  [get_ports w_spi_mosi]

set_input_delay -clock spi_clk -max 5.000  [get_ports w_spi_ss_n0]
set_input_delay -clock spi_clk -min 1.000  [get_ports w_spi_ss_n0]



set_clock_groups -asynchronous -group [get_clocks spi_clk] -group [get_clocks sys_clk]




# XDC - LED_Matrix

# package pin set

# J 20

# Pin assignment table:
# 1     GND     2   +5V         
# 3     R14     4   P14         
# 5     U12     6   T12         
# 7     T15     8   T14         
# 9     T11     10  T10         
# 11    U15     12  U14         
# 13    P19     14  N18         
# 15    R17     16  R16         
# 17    P15     18  P16         
# 19    N17     20  P18         
# 21    V16     22  W16         
# 23    R18     24  T17         
# 25    W19     26  W18
# 27    W20     28  V20
# 29    P20     30  N20
# 31    U17     32  T16
# 33    U20     34  T20
# 35    V15     36  W15
# 37    GND     38  GND
# 39    +3.3V   40  +3.3V


# J 21

# Pin assignment table:
# 1     GND     2   +5V
# 3     M18     4   M17
# 5	    K19	    6	J19
# 7	    B19	    8	A20
# 9	    B20	    10	C20
# 11	G19	    12	G20
# 13	M19	    14	M20
# 15	D20	    16	D19
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





# anode port setting

set_property PACKAGE_PIN P14        [get_ports {w_row_anode[0]}]
set_property PACKAGE_PIN T12        [get_ports {w_row_anode[1]}]
set_property PACKAGE_PIN T14        [get_ports {w_row_anode[2]}]
set_property PACKAGE_PIN T10        [get_ports {w_row_anode[3]}]
set_property PACKAGE_PIN U14        [get_ports {w_row_anode[4]}]
set_property PACKAGE_PIN N18        [get_ports {w_row_anode[5]}]
set_property PACKAGE_PIN R16        [get_ports {w_row_anode[6]}]
set_property PACKAGE_PIN P16        [get_ports {w_row_anode[7]}]

set_property IOSTANDARD  LVCMOS33   [get_ports {w_row_anode[0]}]
set_property IOSTANDARD  LVCMOS33   [get_ports {w_row_anode[1]}]
set_property IOSTANDARD  LVCMOS33   [get_ports {w_row_anode[2]}]
set_property IOSTANDARD  LVCMOS33   [get_ports {w_row_anode[3]}]
set_property IOSTANDARD  LVCMOS33   [get_ports {w_row_anode[4]}]
set_property IOSTANDARD  LVCMOS33   [get_ports {w_row_anode[5]}]
set_property IOSTANDARD  LVCMOS33   [get_ports {w_row_anode[6]}]
set_property IOSTANDARD  LVCMOS33   [get_ports {w_row_anode[7]}]

set_property PULLTYPE PULLDOWN  [get_ports {w_row_anode[*]}]


# Cell setting

# Green
set_property PACKAGE_PIN R14 [get_ports {w_column_cell[0][0]}]
set_property PACKAGE_PIN U12 [get_ports {w_column_cell[1][0]}]
set_property PACKAGE_PIN T15 [get_ports {w_column_cell[2][0]}]
set_property PACKAGE_PIN T11 [get_ports {w_column_cell[3][0]}]
set_property PACKAGE_PIN U15 [get_ports {w_column_cell[4][0]}]
set_property PACKAGE_PIN P19 [get_ports {w_column_cell[5][0]}]
set_property PACKAGE_PIN R17 [get_ports {w_column_cell[6][0]}]
set_property PACKAGE_PIN P15 [get_ports {w_column_cell[7][0]}]

# Red
set_property PACKAGE_PIN N17 [get_ports {w_column_cell[0][1]}]
set_property PACKAGE_PIN V16 [get_ports {w_column_cell[1][1]}]
set_property PACKAGE_PIN R18 [get_ports {w_column_cell[2][1]}]
set_property PACKAGE_PIN W19 [get_ports {w_column_cell[3][1]}]
set_property PACKAGE_PIN W20 [get_ports {w_column_cell[4][1]}]
set_property PACKAGE_PIN P20 [get_ports {w_column_cell[5][1]}]
set_property PACKAGE_PIN U17 [get_ports {w_column_cell[6][1]}]
set_property PACKAGE_PIN U20 [get_ports {w_column_cell[7][1]}]

# Blue
set_property PACKAGE_PIN P18 [get_ports {w_column_cell[0][2]}]
set_property PACKAGE_PIN W16 [get_ports {w_column_cell[1][2]}]
set_property PACKAGE_PIN T17 [get_ports {w_column_cell[2][2]}]
set_property PACKAGE_PIN W18 [get_ports {w_column_cell[3][2]}]
set_property PACKAGE_PIN V20 [get_ports {w_column_cell[4][2]}]
set_property PACKAGE_PIN N20 [get_ports {w_column_cell[5][2]}]
set_property PACKAGE_PIN T16 [get_ports {w_column_cell[6][2]}]
set_property PACKAGE_PIN T20 [get_ports {w_column_cell[7][2]}]

set_property IOSTANDARD LVCMOS33 [get_ports {w_column_cell[*][*]}]
set_property PULLTYPE PULLUP [get_ports {w_column_cell[*][*]}]




# rst_n port setting， for user KEY 1

set_property PACKAGE_PIN M15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]





# SPI xdc

set_property PACKAGE_PIN C20 [get_ports w_spi_ss_n0 ]
set_property PACKAGE_PIN G20 [get_ports w_spi_mosi  ]
set_property PACKAGE_PIN M20 [get_ports w_spi_miso  ]
set_property PACKAGE_PIN D19 [get_ports spi_clk     ]

set_property IOSTANDARD LVCMOS33 [get_ports w_spi_ss_n0 ]
set_property IOSTANDARD LVCMOS33 [get_ports w_spi_mosi  ]
set_property IOSTANDARD LVCMOS33 [get_ports w_spi_miso  ]
set_property IOSTANDARD LVCMOS33 [get_ports spi_clk     ]

set_property PULLTYPE PULLUP    [get_ports w_spi_ss_n0]
set_property PULLTYPE PULLDOWN  [get_ports w_spi_mosi]
set_property PULLTYPE PULLDOWN  [get_ports w_spi_miso]
set_property PULLTYPE PULLDOWN  [get_ports spi_clk]



# w_tx_done

# Use J21 3

set_property PACKAGE_PIN M18 [get_ports w_tx_done]
set_property IOSTANDARD LVCMOS33 [get_ports w_tx_done  ]
set_property PULLTYPE PULLDOWN [get_ports w_tx_done]


# Test LED

set_property PACKAGE_PIN A20 [get_ports w_test_led]
set_property IOSTANDARD LVCMOS33 [get_ports w_test_led]
set_property PULLTYPE PULLDOWN [get_ports w_test_led]