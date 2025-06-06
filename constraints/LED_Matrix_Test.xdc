# Version 1.0

# Warning can be ignored :

# Synthesis         ignore - warning 1 : [Synth 8-7080] Parallel synthesis criteria is not met

# Implementation    ignore - warning 2 : [Device 21-9320] Failed to find the Oracle tile group with name 'HSR_BOUNDARY_TOP'. This is required for Clock regions and Virtual grid.
#                   ignore - warning 3 : [Device 21-2174] Failed to initialize Virtual grid.
#                   ignore - warning 4 : [DRC ZPS7-1] PS7 block required: The PS7 cell must be used in this Zynq design in order to enable correct default configuration.


# XDC - LED_Matrix_Test 

# Clock set

create_clock -period 20.000 -name sys_standard_clk -waveform {0.000 10.000} [get_ports clk]
set_property PACKAGE_PIN U18 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

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




# KEY

# KEY_1 M15
# KEY_2 M14
# KEY_3 L17
# KEY_4 L16


# rst_n port setting， for user KEY 1

set_property PACKAGE_PIN M15 [get_ports rst_n]
set_property IOSTANDARD LVCMOS33 [get_ports rst_n]
set_property PULLTYPE PULLDOWN [get_ports rst_n]

# Key wire

set_property PACKAGE_PIN M14 [get_ports w_key_2]
set_property PACKAGE_PIN L17 [get_ports w_key_3]
set_property PACKAGE_PIN L16 [get_ports w_key_4]

set_property IOSTANDARD LVCMOS33 [get_ports w_key_2]
set_property IOSTANDARD LVCMOS33 [get_ports w_key_3]
set_property IOSTANDARD LVCMOS33 [get_ports w_key_4]


# start wire

set_property PACKAGE_PIN M18 [get_ports start]
set_property IOSTANDARD LVCMOS33 [get_ports start]
set_property PULLTYPE PULLDOWN [get_ports start]


# done wire

set_property PACKAGE_PIN J19 [get_ports w_done]
set_property IOSTANDARD LVCMOS33 [get_ports w_done]
set_property PULLTYPE PULLDOWN [get_ports w_done]

