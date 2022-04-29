; this is a counter
; it will count 0 to FFFF in register A
; how many cycles to wait between each count
; is decided by the d register

; start of program
ldi a,$0000

; increases A by 1
COUNTER:
    addi a,1
    subr WAIT
    ;cmpi a, 0
    ;beq FINISHED
    rjmp COUNTER

; SUBR WAIT
; loops until d = 0
WAIT:
    ldi d,$0FFF
WAIT_LOOP:
    subi d,1
    bne WAIT_LOOP
    ret

; eternity loop
FINISHED:
    ldi a,$1337
    nop
    rjmp -1
