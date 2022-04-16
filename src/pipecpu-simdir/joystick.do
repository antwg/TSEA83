# Build CPU
vcom "+acc" ../Joystick/joystick.vhd
# Build memory files
vcom "+acc" ../Joystick/ClkDiv_5Hz.vhd ../Joystick/ClkDiv_66_67kHz.vhd ../Joystick/PmodJSTK_Demo.vhd ../Joystick/PmodJSTK.vhd ../Joystick/spiCtrl.vhd ../Joystick/spiMode0.vhd

# Build relevant testbench
vcom "+acc" ../tbs/joystick_tb.vhd

# Simulate testbench
vsim joystick_tb 

# Wave configurations
config wave -signalnamewidth 1

add wave {sim:/joystick_tb/J_CMP/joystick_sync_cnt}
add wave {sim:/joystick_tb/J_CMP/SCLK}
add wave {sim:/joystick_tb/J_CMP/clk}
add wave {sim:/joystick_tb/J_CMP/PmodJTK_Demo/sndRec}
add wave {sim:/joystick_tb/J_CMP/PmodJTK_Demo/genSndRec/CLKOUT}
add wave {sim:/joystick_tb/J_CMP/PmodJTK_Demo/genSndRec/RST}
add wave {sim:/joystick_tb/J_CMP/PmodJTK_Demo/genSndRec/clkCount}


restart -f
run 600 ms 