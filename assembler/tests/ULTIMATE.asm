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
cmpi a, 64
beq 2
ldi a, 0
addi a, 6 ; a = 70 if beq and flags work
cmpi a, 63 
beq 2 ; false
addi 2 ; a = 72 
cmpi a, 2 
bne 2 ; false
ldi a, 0
cmp a, a 
bne 2 ; true
addi a, 2 ; a = 74
cmpi a, 1
bpl 2 ; true
ldi a, 0
cmpi a, 100
bpl 2 ; false
addi a, 2 ; a = 76
cmpi a, 100
bmi 2 ; true
ldi a, 0
cmpi a, 1
bmi 2 ; false
addi a, 2 ; a = 78
cmpi a, 10 ; is greater
bge 2 ; true
ldi a, 0
cmp a, a 
bge 2 ; true
ldi a, 0
cmpi a, 100; is lower
bge 2 ; fail
addi a, 2 ; a = 80
cmpi a, 100
blt 2 ; true
ldi a, 0
cmp a, a 
blt 2 ; false
addi a, 2 ; a = 82
cmpi a, 4
blt 2 ; false
addi a, 2 ; a = 84
lsrs a ; a = 42
lsrs a ; a = 21
subi a, 16 ; a = 5
nop
rjmp -1
