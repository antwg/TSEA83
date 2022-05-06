# Documentation: https://www.microsemi.com/document-portal/doc_view/136364-modelsim-me-10-4c-command-reference-manual-for-libero-soc-v11-7

# Build CPU
vcom "+acc" ../pipeCPU.vhd
# Build memory files
vcom "+acc"  ../MEM/DATA_MEM.vhd ../MEM/REG_FILE.vhd ../MEM/PROG_MEM.vhd ../MEM/PROG_LOADER.vhd ../alu.vhd ../VGA_MOTOR.vhd
# Build relevant testbench
vcom "+acc" ../tbs/pipeCPU_tb.vhd

# Simulate testbench
vsim pipeCPU_tb

# Wave configurations
config wave -signalnamewidth 1

add wave {sim:/pipecpu_tb/clk}
add wave {sim:/pipecpu_tb/rst}
add wave -dec -group pcir {sim:/pipecpu_tb/U0/PC}
add wave -group pcir {sim:/pipecpu_tb/U0/IR1}
add wave -dec -group pcir {sim:/pipecpu_tb/U0/PC1}
add wave -group pcir {sim:/pipecpu_tb/U0/IR2}
add wave -dec -group pcir {sim:/pipecpu_tb/U0/jumping}
add wave -dec -group pcir {sim:/pipecpu_tb/U0/JUMP_PC}
add wave -group intr {sim:/pipecpu_tb/U0/interrupt_en}
add wave -group intr {sim:/pipecpu_tb/U0/interrupt}
add wave -group intr {sim:/pipecpu_tb/U0/interrupt_handling}
add wave -group intr {sim:/pipecpu_tb/U0/interrupt_handling_jump}
add wave -group cpu {sim:/pipecpu_tb/U0/SP}
add wave -group cpu {sim:/pipecpu_tb/U0/status_reg_out}
add wave -group cpu {sim:/pipecpu_tb/U0/sr_we}
add wave -group cpu {sim:/pipecpu_tb/U0/data_bus}
add wave -group cpu {sim:/pipecpu_tb/U0/IR2_ra}
add wave -group cpu {sim:/pipecpu_tb/U0/IR2_rd}
add wave -group cpu {sim:/pipecpu_tb/U0/alu_mux1}
add wave -group cpu {sim:/pipecpu_tb/U0/alu_mux2}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/we}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/rd_in}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/rd_out}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/ra_in}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/ra_out}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/data_in}
add wave -group rf {sim:/pipecpu_tb/U0/reg_file_comp/RF}
add wave -group PM {sim:/pipecpu_tb/U0/pm_addr}
add wave -group PM {sim:/pipecpu_tb/U0/PMdata_out}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/MUX1}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/MUX2}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/op_code}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/result}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/result_large}
add wave -group ALU {sim:/pipecpu_tb/U0/alu_comp/status_reg}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/DM}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/addr}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/data_out}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/data_in}
add wave -group dm {sim:/pipecpu_tb/U0/data_mem_comp/we}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/rst}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/rx}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/done}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/boot_en}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/we}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/addr}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/data_out}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/rx1}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/rx2}
add wave -group boot {sim:/pipecpu_tb/U0/prog_loader_comp/st_868_cnt_out}
add wave -unsigned {sim:/pipecpu_tb/U0/leddriver_comp/value} 

add wave -hex {sim:/pipecpu_tb/U0/sprite_mem_comp/spriteData}
add wave -hex {sim:/pipecpu_tb/U0/sprite_mem_comp/spriteWrite}
add wave -hex {sim:/pipecpu_tb/U0/sprite_mem_comp/spriteOut}
add wave -hex {sim:/pipecpu_tb/U0/sprite_mem_comp/spriteListPos}   
add wave -hex {sim:/pipecpu_tb/U0/sprite_mem_comp/collision}
add wave -bin {sim:/pipecpu_tb/U0/dm_and_sm_data_out}
add wave -hex {sim:/pipecpu_tb/U0/alu_out}

add wave -bin {sim:/pipecpu_tb/U0/sprite_mem_comp/spriteList}




restart -f
run 200 ns
