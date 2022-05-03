;; Some examples to show the syntax of the assembly.

ldi b,0                         ; load register b (RF(1)) with value 0
rjmp START                      ; jump to label START

START:                          ; a label that points to the instruction below it
    ldi a,$F0C0                 ; load register with hex value
    cmp a,b                     ; compare two registers
    beq FINISHED                ; jump if comparison set Z flag to 0
    rjmp LOAD_B

LOAD_B:
    subi a,4                    ; subtract 4 from a
    ldi b,$F0C0                 ; load b with hex value
    rjmp START

FINISHED:
    ldi a,#10100111001          ; load a with binary (1337 in dec)
FINISHED_LOOP:
    nop                         ; nooperation
    rjmp -1                     ; jump back one step
