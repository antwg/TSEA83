ldi a, 10
ldi b, 4
sub a, b ; a = 6
addi a, 2 ; a = 8
subi b, 2 ; b = 2
add a, b ; a = 10
lsrs a ; a = 5
muli, a, 3 ; a = 15
lsls b ; b = 4
mul a, b ; a = 60
st b, a ; store a = 60 on addr b = 4
ldi a, 0 ; a = 0
ld a, b ; a = 60
mulsi a, -1 ; a = -60 
andi a, 7  ; a = 4
ldi b, 8
or a, b ; a = 12  
ori a, 16; a = 28
and a, b; a = 8
muls a, a ; a = 64
nop
rjmp -1
