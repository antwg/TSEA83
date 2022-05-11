ldi b, 31
ldi c, 8223
ldi d, 64512
ldi e,64513
ldi f, 65000
ldi g,40
st d,b
st e,c
ld b,d
addi b,1
st d,b
subi f,1
bne -1
ldi f,65000
subi g,1
bne -4
ldi g,40
rjmp -9