; test instructions...
ldi a,2
copy b,a
STI a,3
ldi a,7
ld a,b
NOP
RJMP -1
