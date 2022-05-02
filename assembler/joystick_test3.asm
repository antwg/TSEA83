;init
LDI P,0
LDI O,0

LDI a, 65000
SUBI a, 1
CMPI a, 0
BNE -2

LDI P, 32768 ; load enable bit 1000000000000000
; wait for result
LDI b, 5000
LDI a, 65000
SUBI a, 1
CMPI a, 0
BNE -2
subi b, 1
CMPI b, 0
BNE -6

ANDI p, 32767 ; disable joystick
COPY p,c ; move read bits 

; wait a lot to make 7seg readable
LDI b, 5000 
LDI a, 65000
SUBI a, 1
CMPI a, 0
BNE -2
subi b, 1
CMPI b, 0
BNE -6

RJMP -23 ;start again 
NOP
RJMP -1