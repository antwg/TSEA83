# Documentation: https://www.microsemi.com/document-portal/doc_view/136364-modelsim-me-10-4c-command-reference-manual-for-libero-soc-v11-7

# Build CPU
vcom "+acc" ../pipeCPU.vhd
# Build memory files
vcom "+acc"  ../MEM/DATA_MEM.vhd ../MEM/REG_FILE.vhd ../MEM/PROG_MEM.vhd ../MEM/PROG_LOADER.vhd ../alu.vhd ../uart_com.vhd
# Build relevant testbench
vcom "+acc" ../tbs/sendbyte_tb.vhd

# Simulate testbench
vsim sendbyte_tb

# Wave configurations
config wave -signalnamewidth 1

add wave {sim:/sendbyte_tb/clk}
add wave {sim:/sendbyte_tb/rst}
add wave -group ir {sim:/sendbyte_tb/U0/IR1}
add wave -group ir {sim:/sendbyte_tb/U0/IR2}
add wave -dec -group pc {sim:/sendbyte_tb/U0/PC}
add wave -hex -group pc {sim:/sendbyte_tb/U0/PC1}
add wave -hex -group pc {sim:/sendbyte_tb/U0/JUMP_PC}
add wave {sim:/sendbyte_tb/U0/pm_addr}
add wave -color gold {sim:/sendbyte_tb/U0/PMdata_out}

add wave -group reg {sim:/sendbyte_tb/U0/IR2_ra}
add wave -group reg {sim:/sendbyte_tb/U0/IR2_rd}
add wave -group reg -color gold {sim:/sendbyte_tb/U0/alu_mux1}
add wave -group reg -color gold {sim:/sendbyte_tb/U0/alu_mux2}

add wave -group pm {sim:/sendbyte_tb/U0/prog_mem_comp/addr}
add wave -group pm {sim:/sendbyte_tb/U0/prog_mem_comp/data_out}
add wave -group pm {sim:/sendbyte_tb/U0/prog_mem_comp/we}
add wave -group pm {sim:/sendbyte_tb/U0/prog_mem_comp/wr_addr}
add wave -group pm -hex {sim:/sendbyte_tb/U0/prog_mem_comp/wr_data}
add wave -group pm -hex {sim:/sendbyte_tb/U0/prog_mem_comp/PM}

add wave -group ALU {sim:/sendbyte_tb/U0/alu_comp/MUX1}
add wave -group ALU {sim:/sendbyte_tb/U0/alu_comp/MUX2}
add wave -group ALU {sim:/sendbyte_tb/U0/alu_comp/op_code}
add wave -group ALU {sim:/sendbyte_tb/U0/alu_comp/result}
add wave -group ALU {sim:/sendbyte_tb/U0/alu_comp/status_reg}

add wave -group rf {sim:/sendbyte_tb/U0/reg_file_comp/we}
add wave -group rf {sim:/sendbyte_tb/U0/reg_file_comp/rd_in}
add wave -group rf {sim:/sendbyte_tb/U0/reg_file_comp/rd_out}
add wave -group rf {sim:/sendbyte_tb/U0/reg_file_comp/ra_in}
add wave -group rf {sim:/sendbyte_tb/U0/reg_file_comp/ra_out}
add wave -group rf {sim:/sendbyte_tb/U0/reg_file_comp/data_in}
add wave -group rf {sim:/sendbyte_tb/U0/reg_file_comp/RF}

add wave -group dm {sim:/sendbyte_tb/U0/data_mem_comp/DM}
add wave -group dm {sim:/sendbyte_tb/U0/data_mem_comp/addr}
add wave -group dm {sim:/sendbyte_tb/U0/data_mem_comp/data_out}
add wave -group dm {sim:/sendbyte_tb/U0/data_mem_comp/data_in}
add wave -group dm {sim:/sendbyte_tb/U0/data_mem_comp/we}

add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/boot_on}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/rst}
add wave -group boot {sim:/sendbyte_tb/U0/UART_IN}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/rx}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/done}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/ke_done}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/we}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/we_en}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/we_en1}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/we_en2}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/fullInstr}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/addr}
add wave -group boot -hex {sim:/sendbyte_tb/U0/prog_loader_comp/data_out}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/rx1}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/rx2}
add wave -group boot -uns {sim:/sendbyte_tb/U0/prog_loader_comp/st_868_cnt_out}
add wave -group boot -uns {sim:/sendbyte_tb/U0/prog_loader_comp/st_10_cnt_out}
add wave -group boot -uns {sim:/sendbyte_tb/U0/prog_loader_comp/st_4_cnt_out}
add wave -group boot {sim:/sendbyte_tb/U0/prog_loader_comp/sp}
add wave -group boot -bin {sim:/sendbyte_tb/U0/prog_loader_comp/byteReg}
add wave -group boot -hex {sim:/sendbyte_tb/U0/prog_loader_comp/instrReg}

add wave -group uart -bin {sim:/sendbyte_tb/U0/uart_com_comp/send_byte}
add wave -group uart -bin {sim:/sendbyte_tb/U0/uart_com_comp/tx_byte}
add wave -group uart -bin {sim:/sendbyte_tb/U0/uart_com_comp/bit_out}
add wave -group uart {sim:/sendbyte_tb/U0/uart_com_comp/done}
add wave -group uart {sim:/sendbyte_tb/U0/uart_com_comp/send}
add wave -group uart {sim:/sendbyte_tb/U0/uart_com_comp/sent}
add wave -group uart {sim:/sendbyte_tb/U0/uart_com_comp/stop_bit}
add wave -group uart {sim:/sendbyte_tb/U0/uart_com_comp/start_bit}
add wave -group uart -hex {sim:/sendbyte_tb/U0/uart_com_comp/rp}
add wave -group uart {sim:/sendbyte_tb/U0/uart_com_comp/st_868_cnt_en}
add wave -group uart {sim:/sendbyte_tb/U0/uart_com_comp/st_868_cnt_rst}
add wave -group uart -dec {sim:/sendbyte_tb/U0/uart_com_comp/st_868_cnt_out}
add wave -group uart {sim:/sendbyte_tb/U0/uart_com_comp/st_8_cnt_en}
add wave -group uart {sim:/sendbyte_tb/U0/uart_com_comp/st_8_cnt_rst}
add wave -group uart -dec {sim:/sendbyte_tb/U0/uart_com_comp/st_8_cnt_out}

add wave {sim:/sendbyte_tb/U0/leddriver_comp/value}

restart -f
run 11150000 ns
