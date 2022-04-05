LDI a,4
LDI b,69
SUBI a,2
STI b,a ; spara A(2) på adress 69
NOP
RJMP -2
