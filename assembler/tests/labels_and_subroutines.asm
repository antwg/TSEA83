; this is a counter
; it will count 0 to FFFF in register A
; when it's done it will display $1337 on the 7-seg display.
; how many cycles to wait between each count
; is decided by the d register

; start of program
; load a hexadecimal value with prefixing the hex with $.
ldi n,$0000

; load a binary value by prefixing it with #.
ldi n,#010101010111

; increases A by 1
COUNTER:
    addi n,1 ; load a decimal value by simply writing the decimal
    subr WAIT
    cmpi n, 0
    beq FINISHED
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
    ldi n,$1337
    nop
    rjmp -1
