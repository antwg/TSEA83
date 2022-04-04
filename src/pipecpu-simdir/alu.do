# Documentation: https://www.microsemi.com/document-portal/doc_view/136364-modelsim-me-10-4c-command-reference-manual-for-libero-soc-v11-7

# Build CPU
vcom "+acc" ../alu.vhd
# Build relevant testbench
vcom "+acc" ../tbs/alu_tb.vhd

# Simulate testbench
vsim alu_tb

config wave -signalnamewidth 1

add wave {sim:/U0/clk}
add wave -dec {sim:/U0/result}
add wave -dec {sim:/U0/MUX1}
add wave -dec {sim:/U0/MUX2}
add wave {sim:/U0/op_code}

restart -f
run 1000 ns
