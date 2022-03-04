vcom "+acc" ../pipeCPU.vhd ../PM/PM.vhd
vcom "+acc" ../pipeCPU_tb.vhd
vsim pipeCPU_tb

config wave -signalnamewidth 1
add wave {sim:/pipecpu_tb/clk}
add wave {sim:/pipecpu_tb/rst}
add wave -group ir {sim:/pipecpu_tb/U0/IR1}
add wave -group ir {sim:/pipecpu_tb/U0/IR2}
add wave -dec -group pc {sim:/pipecpu_tb/U0/PC}
add wave -hex -group pc {sim:/pipecpu_tb/U0/PC1}
add wave -hex -group pc {sim:/pipecpu_tb/U0/PC2}
add wave -color gold {sim:/pipecpu_tb/U0/PMdata_out}
add wave {sim:/pipecpu_tb/U0/pm_addr}

restart -f
run 20 us
