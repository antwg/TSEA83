;init
LDI P,0
LDI O,0

LDI a, 65000
SUBI a, 1
CMPI a, 0
BNE -2

LDI P, 32768 ; load enable bit 1000000000000000
; wait for result, one read takes 4000*40 cycles so 500*4000 should be enough
LDI b, 500 
LDI a, 4000 
SUBI a, 1
CMPI a, 0
BNE -2
subi b, 1
CMPI b, 0
BNE -6

ANDI p, 32767 ; disable joystick 0111111111111111
COPY p,c ; move read bits  to c

; wait a lot to make 7seg readable
;LDI b, 500 
;LDI a, 65000
;SUBI a, 1
;CMPI a, 0
;BNE -2
;subi b, 1
;CMPI b, 0
;BNE -6

RJMP -23 ;start again 
NOP
RJMP -1 ; just in case we loop at the end