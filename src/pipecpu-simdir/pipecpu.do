vcom "+acc" ../pipeCPU.vhd ../MEM/DATA_MEM.vhd
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
add wave -group reg -color gold {sim:/pipecpu_tb/U0/alu_mux1}
add wave -group reg -color gold {sim:/pipecpu_tb/U0/alu_mux2}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/rst}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/rx}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/done}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/we}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/addr}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/data_out}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/rx1}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/rx2}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/sreg}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/st_868_cnt_out}
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/st_26_cnt_out}
add wave -group pmLoader {sim:/pipecpu_tb/U0/boot_done}

restart -f
run 1000 ns
