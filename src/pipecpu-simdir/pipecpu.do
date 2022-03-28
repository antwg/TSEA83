vcom "+acc" ../pipeCPU.vhd ../MEM/PRIM_MEM.vhd
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
add wave {sim:/pipecpu_tb/U0/pm_addr}
add wave -color gold {sim:/pipecpu_tb/U0/PMdata_out}
add wave -group reg {sim:/pipecpu_tb/U0/IR2_ra}
add wave -group reg {sim:/pipecpu_tb/U0/IR2_rd}
add wave -group reg -color gold {sim:/pipecpu_tb/U0/ALU_dummy1}
add wave -group reg -color gold {sim:/pipecpu_tb/U0/ALU_dummy2}

restart -f
run 1000 ns
