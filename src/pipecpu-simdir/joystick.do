# Build joystick
vcom "+acc" ../Joystick/joystickreal.vhd


# Build relevant testbench
vcom "+acc" ../tbs/joystick_tb.vhd

# Simulate testbench
vsim joystick_tb 

# Wave configurations
config wave -signalnamewidth 1

add wave {sim:/joystick_tb/J_CMP/clk}
add wave {sim:/joystick_tb/J_CMP/JA}
add wave -uns {sim:/joystick_tb/J_CMP/bits_sent}
add wave {sim:/joystick_tb/J_CMP/sclk_counter}
add wave {sim:/joystick_tb/J_CMP/RST}
add wave {sim:/joystick_tb/J_CMP/enable}
add wave {sim:/joystick_tb/J_CMP/data_out}
add wave {sim:/joystick_tb/J_CMP/done}
add wave -group spi {sim:/joystick_tb/J_CMP/SS}
add wave -group spi {sim:/joystick_tb/J_CMP/MOSI}
add wave -group spi {sim:/joystick_tb/J_CMP/MISO}
add wave -group spi {sim:/joystick_tb/J_CMP/SCLK}


restart -f
run 1 ms 