;init
LDI P,0
LDI O,0

LDI a, 65000
SUBI a, 1
CMPI a, 0
BNE -2

LDI P, 32768 ; load enable bit 1000000000000000
; wait for result, one read takes 4000*40 cycles so 50*4000 should be enough
LDI b, 50 
LDI a, 4000 
SUBI a, 1
CMPI a, 0
BNE -2
subi b, 1
CMPI b, 0
BNE -6

COPY c,p ; move x and btns read bits  to c
COPY n,o ; move x and btns read bits  to c

ANDI c, 32767 ; disable joystick 0111111111111111
ANDI n, 32767 ; disable joystick 0111111111111111
ANDI p, 32767 ; disable joystick 0111111111111111

; wait a lot to make 7seg readable
LDI b, 200
LDI a, 65000
SUBI a, 1
CMPI a, 0
BNE -2
subi b, 1
CMPI b, 0
BNE -6

COPY c,n ; move y read bits  to c

LDI b, 200
LDI a, 65000
SUBI a, 1
CMPI a, 0
BNE -2
subi b, 1
CMPI b, 0
BNE -6


RJMP -32 ;start again 
NOP
RJMP -1 ; just in case we loop at the end