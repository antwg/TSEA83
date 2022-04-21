# Documentation: https://www.microsemi.com/document-portal/doc_view/136364-modelsim-me-10-4c-command-reference-manual-for-libero-soc-v11-7

# Build CPU
vcom "+acc" ../pipeCPU.vhd
# Build memory files
vcom "+acc"  ../MEM/DATA_MEM.vhd ../MEM/REG_FILE.vhd ../MEM/PROG_MEM.vhd ../MEM/PROG_LOADER.vhd ../alu.vhd
# Build relevant testbench
vcom "+acc" ../tbs/pipeCPU_tb.vhd

# Simulate testbench
vsim pipeCPU_tb

# Wave configurations
config wave -signalnamewidth 1

add wave {sim:/pipecpu_tb/clk}
add wave {sim:/pipecpu_tb/rst}
add wave -group ir {sim:/pipecpu_tb/U0/IR1}
add wave -group ir {sim:/pipecpu_tb/U0/IR2}
add wave -dec -group pc {sim:/pipecpu_tb/U0/PC}
add wave -hex -group pc {sim:/pipecpu_tb/U0/PC1}
add wave -hex -group pc {sim:/pipecpu_tb/U0/JUMP_PC}
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
add wave -group pmLoader {sim:/pipecpu_tb/U0/prog_loader_comp/st_868_cnt_out}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/MUX1}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/MUX2}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/op_code}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/result}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/status_reg}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/we}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/rd_in}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/rd_out}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/ra_in}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/ra_out}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/data_in}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/RF}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/DM}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/addr}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/data_out}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/data_in}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/we}
add wave {sim:/pipecpu_tb/U0/leddriver_comp/value}
add wave -group vga {sim:/pipecpu_tb/U0/vgaRed}
add wave -group vga {sim:/pipecpu_tb/U0/vgaBlue}
add wave -group vga {sim:/pipecpu_tb/U0/vgaGreen}
add wave -group vga {sim:/pipecpu_tb/U0/Hsync}
add wave -group vga {sim:/pipecpu_tb/U0/Vsync}
add wave -group vga {sim:/pipecpu_tb/U0/sprite_mem_comp/clk}
add wave -group vga {sim:/pipecpu_tb/U0/sprite_mem_comp/Xpixel}
#add wave -group vga {sim:/pipecpu_tb/U0/rx1}
#add wave -group vga {sim:/pipecpu_tb/U0/rx2}
#add wave -group vga {sim:/pipecpu_tb/U0/st_868_cnt_out}


restart -f
run 1000 ns
