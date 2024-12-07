# Clock signal
set_property PACKAGE_PIN W5 [get_ports clk_100MHz]							
	set_property IOSTANDARD LVCMOS33 [get_ports clk_100MHz]
	create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk_100MHz]
	
# LEDs
set_property PACKAGE_PIN U16 	 [get_ports {rx_full}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rx_full}]
set_property PACKAGE_PIN E19 	 [get_ports {rx_empty}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rx_empty}]

set_property PACKAGE_PIN U19 	 [get_ports {rx_done_tick}]					
set_property IOSTANDARD LVCMOS33 [get_ports {rx_done_tick}]
set_property PACKAGE_PIN V19 	 [get_ports {tx_done_tick}]					
set_property IOSTANDARD LVCMOS33 [get_ports {tx_done_tick}]

set_property PACKAGE_PIN W18 	 [get_ports {read_flag}]					
set_property IOSTANDARD LVCMOS33 [get_ports {read_flag}]
set_property PACKAGE_PIN U15 	 [get_ports {write_flag}]					
set_property IOSTANDARD LVCMOS33 [get_ports {write_flag}]

# switch 7 onwards
set_property PACKAGE_PIN U14 	 [get_ports {write_data_reg[0]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {write_data_reg[0]}]
set_property PACKAGE_PIN V14 	 [get_ports {write_data_reg[1]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {write_data_reg[1]}]
set_property PACKAGE_PIN V13 	 [get_ports {write_data_reg[2]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {write_data_reg[2]}]
set_property PACKAGE_PIN V3 	 [get_ports {write_data_reg[3]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {write_data_reg[3]}]
set_property PACKAGE_PIN W3 	 [get_ports {write_data_reg[4]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {write_data_reg[4]}]
set_property PACKAGE_PIN U3 	 [get_ports {write_data_reg[5]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {write_data_reg[5]}]
set_property PACKAGE_PIN P3 	 [get_ports {write_data_reg[6]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {write_data_reg[6]}]
set_property PACKAGE_PIN N3 	 [get_ports {write_data_reg[7]}]					
set_property IOSTANDARD LVCMOS33 [get_ports {write_data_reg[7]}]


set_property PACKAGE_PIN L1 	 [get_ports {signal_debugging}]					
set_property IOSTANDARD LVCMOS33 [get_ports {signal_debugging}]


#7 segment display
#set_property PACKAGE_PIN W7 	 [get_ports {seg[0]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
#set_property PACKAGE_PIN W6 	 [get_ports {seg[1]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
#set_property PACKAGE_PIN U8 	 [get_ports {seg[2]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
#set_property PACKAGE_PIN V8 	 [get_ports {seg[3]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
#set_property PACKAGE_PIN U5 	 [get_ports {seg[4]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
#set_property PACKAGE_PIN V5 	 [get_ports {seg[5]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
#set_property PACKAGE_PIN U7 	 [get_ports {seg[6]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]

#set_property PACKAGE_PIN U2 	 [get_ports {an[0]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
#set_property PACKAGE_PIN U4 	 [get_ports {an[1]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
#set_property PACKAGE_PIN V4 	 [get_ports {an[2]}]					
#set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
#set_property PACKAGE_PIN W4 	 [get_ports {an[3]}]0..............					
#set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

###Switches
### SW0
set_property PACKAGE_PIN V17 	 [get_ports input_switch]						
set_property IOSTANDARD LVCMOS33 [get_ports input_switch]

###Buttons
### btnL
set_property PACKAGE_PIN W19 	 [get_ports read_uart_btn]						
set_property IOSTANDARD LVCMOS33 [get_ports read_uart_btn]

### btnC
set_property PACKAGE_PIN U18 	 [get_ports write_uart_btn]						
set_property IOSTANDARD LVCMOS33 [get_ports write_uart_btn]

### btnR
set_property PACKAGE_PIN T17 	 [get_ports reset_btn]						
set_property IOSTANDARD LVCMOS33 [get_ports reset_btn]

##USB-RS232 Interface
set_property PACKAGE_PIN B18 [get_ports rx]						
set_property IOSTANDARD LVCMOS33 [get_ports rx]

set_property PACKAGE_PIN A18 [get_ports tx]						
set_property IOSTANDARD LVCMOS33 [get_ports tx]