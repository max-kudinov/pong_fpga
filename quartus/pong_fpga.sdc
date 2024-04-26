create_clock -period "50.0 MHz" [get_ports {clk_i*}]

derive_clock_uncertainty

set_false_path -from       [get_ports {key_i[*]}] -to [all_clocks]
set_false_path -from * -to [get_ports {led_o[*]}]

set_false_path -from * -to vga_vs_o
set_false_path -from * -to vga_hs_o
set_false_path -from * -to [get_ports {vga_rgb_o[*]}]
