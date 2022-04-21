# Build joystick
vcom "+acc" ../Joystick/joystickreal.vhd


# Build relevant testbench
vcom "+acc" ../tbs/joystick_tb.vhd

# Simulate testbench
vsim joystick_tb 

# Wave configurations
config wave -signalnamewidth 1

add wave {sim:/joystick_tb/J_CMP/SCLK}
add wave {sim:/joystick_tb/J_CMP/clk}
add wave {sim:/joystick_tb/J_CMP/MISO}
add wave {sim:/joystick_tb/J_CMP/MOSI}
add wave {sim:/joystick_tb/J_CMP/SS}
add wave {sim:/joystick_tb/J_CMP/bits_sent}
add wave {sim:/joystick_tb/J_CMP/sclk_counter}
add wave {sim:/joystick_tb/J_CMP/RST}


restart -f
run 1 ms 