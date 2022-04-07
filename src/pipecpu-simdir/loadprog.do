# documentation: https://www.microsemi.com/document-portal/doc_view/136364-modelsim-me-10-4c-command-reference-manual-for-libero-soc-v11-7

# Build CPU
vcom "+acc" ../pipeCPU.vhd
# Build memory files
vcom "+acc"  ../MEM/DATA_MEM.vhd ../MEM/REG_FILE.vhd ../MEM/PROG_MEM.vhd ../MEM/PROG_LOADER.vhd
# Build relevant testbench
vcom "+acc" ../tbs/prog_load_tb.vhd

# Simulate testbench
vsim prog_load_tb

config wave -signalnamewidth 1

add wave {sim:/prog_load_tb/clk}
add wave {sim:/prog_load_tb/rst}
add wave -group ir {sim:/prog_load_tb/U0/IR1}
add wave -group ir {sim:/prog_load_tb/U0/IR2}
add wave -dec -group pc {sim:/prog_load_tb/U0/PC}
add wave -hex -group pc {sim:/prog_load_tb/U0/PC1}
add wave -hex -group pc {sim:/prog_load_tb/U0/PC2}
add wave -group reg {sim:/prog_load_tb/U0/IR2_ra}
add wave -group reg {sim:/prog_load_tb/U0/IR2_rd}
add wave -group reg -color gold {sim:/prog_load_tb/U0/alu_mux1}
add wave -group reg -color gold {sim:/prog_load_tb/U0/alu_mux2}
add wave -group pm {sim:/prog_load_tb/U0/prog_mem_comp/addr}
add wave -group pm {sim:/prog_load_tb/U0/prog_mem_comp/data_out}
add wave -group pm {sim:/prog_load_tb/U0/prog_mem_comp/we}
add wave -group pm {sim:/prog_load_tb/U0/prog_mem_comp/wr_addr}
add wave -group pm -hex {sim:/prog_load_tb/U0/prog_mem_comp/wr_data}
add wave -group pm -hex {sim:/prog_load_tb/U0/prog_mem_comp/PM}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/rst}
add wave -group pmLoader {sim:/prog_load_tb/U0/UART_IN}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/rx}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/done}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/ke_done}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/we}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/we_en}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/we_en1}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/we_en2}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/fullInstr}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/addr}
add wave -group pmLoader -hex {sim:/prog_load_tb/U0/prog_loader_comp/data_out}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/rx1}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/rx2}
add wave -group pmLoader -uns {sim:/prog_load_tb/U0/prog_loader_comp/st_868_cnt_out}
add wave -group pmLoader -uns {sim:/prog_load_tb/U0/prog_loader_comp/st_10_cnt_out}
add wave -group pmLoader -uns {sim:/prog_load_tb/U0/prog_loader_comp/st_4_cnt_out}
add wave -group pmLoader {sim:/prog_load_tb/U0/prog_loader_comp/sp}
add wave -group pmLoader -bin {sim:/prog_load_tb/U0/prog_loader_comp/byteReg}
add wave -group pmLoader -hex {sim:/prog_load_tb/U0/prog_loader_comp/instrReg}

restart -f
run 2000000 ns
