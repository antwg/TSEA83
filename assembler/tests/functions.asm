    ldi a, 0
    ldi b, 1000

START:
    subr SEC_TIMER
    subr RAND_NUM_GEN
    rjmp START

; --------------------------
; ~ A 1 millisecond
; In: -
; Out: -
; --------------------------
MS_TIMER:
    push b
    push c
    ldi b, 249
    ldi c, 100
MS_TIMER_OUTER_LOOP:           ; 4 ticks per loop
    subi b, 1
    bne MS_TIMER_OUTER_LOOP
MS_TIMER_INNER_LOOP:
    ldi b, 249
    subi c, 1
    bne MS_TIMER_OUTER_LOOP
MS_TIMER_END:
    pop c
    pop b
    ret

; --------------------------
; ~ A 1 second delay
; In: -
; Out: -
; --------------------------
SEC_TIMER:
    push b
    ldi b, 1000
SEC_TIMER_LOOP:
    subr MS_TIMER
    subi b, 1
    bne SEC_TIMER_LOOP
SEC_TIMER_END:
    pop b
    ret


; --------------------------
; Returns a pseudorandom num
; between 0 and F in Reg A
; Uses Reg G to store seq
; In: (G)
; Out: A
; --------------------------
RAND_NUM_GEN:
    push b
    push c
    push d
    ldi b, 16301 ; Two large prime numbers
    ldi c, 46181
    ldi d, 5
RAND_NUM_GEN_LOOP: ; Loop 5 times
    add g, b
    muls g, c
    subi d, 1
    bne RAND_NUM_GEN_LOOP
RAND_NUM_GEN_END: ; Mask last byte
    copy a, g
    andi a, $000F
    pop d
    pop c
    pop b
    ret
