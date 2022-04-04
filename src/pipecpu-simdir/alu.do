# Documentation: https://www.microsemi.com/document-portal/doc_view/136364-modelsim-me-10-4c-command-reference-manual-for-libero-soc-v11-7

# Build CPU
vcom "+acc" ../alu.vhd
# Build relevant testbench
vcom "+acc" ../tbs/alu_tb.vhd

# Simulate testbench
vsim alu_tb

config wave -signalnamewidth 1

add wave {sim:/U0/clk}
add wave -uns {sim:/U0/result}
add wave -uns {sim:/U0/MUX1}
add wave -uns {sim:/U0/MUX2}
add wave {sim:/U0/op_code}
add wave {sim:/U0/Z}
add wave {sim:/U0/C}
add wave {sim:/U0/V}
add wave {sim:/U0/N}
add wave -uns {sim:/U0/result_large}
restart -f
run 2 ms
