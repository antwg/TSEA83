    ;ldi a, 0
    ;ldi b, $FC00
    ;ldi c, $FC01
    subr GET_SPAWN_LOC
    subr GET_SPAWN_LOC
    subr MS_TIMER
    subr MS_TIMER
    subr MS_TIMER
    subr MS_TIMER
    

START:
    ;ld a, b
    ;addi a, 1
    ;st b, a
    ;ld a, c
    ;addi a, 1
    ;st c, a
    
    rjmp START

; --------------------------
; ~ A 1 ms delay
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
; ~ A 1/10 second delay
; In: -
; Out: -
; --------------------------
TENTH_TIMER:
    push b
    ldi b, 100
TENTH_TIMER_LOOP:
    subr MS_TIMER
    subi b, 1
    bne TENTH_TIMER_LOOP
TENTH_TIMER_END:
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
; between 0 and FFFF in Reg A
; Uses Reg G to store progress
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
    pop d
    pop c
    pop b
    ret

; --------------------------
; Returns a valid spawn location
; for an asteroid
; FC00 -> xpixel 8 bitar låga
;   01-> 3 bitar (vilken sprite höga) + 8 bitar ypixel (låga)
; Stor asteroid 010
; --------------------------

GET_SPAWN_LOC:
    push a ; Random number
    push b ; xpixel (8 low)
    push c ; which sprite (3 high) and ypixel (8 low)

    ; Choose left or right
    subr RAND_NUM_GEN
    copy b, a
    andi b, $0003
    cmpi b, 0
    beq GET_SPAWN_LEFT
    cmpi b, 1
    beq GET_SPAWN_LOC_RIGHT
    cmpi b, 2
    beq GET_SPAWN_LOC_BOTTOM

GET_SPAWN_LOC_TOP:
    copy b, a       ; Xpixel = random
    andi b, $00FF
    ldi c, $4000     ; Ypixel = 0, large asteroid
    rjmp GET_SPAWN_LOC_END

GET_SPAWN_LOC_BOTTOM:
    copy b, a       ; Xpixel = random
    andi b, $00FF
    ldi c, $4082     ; Ypixel = 130, large asteroid
    rjmp GET_SPAWN_LOC_END

GET_SPAWN_LOC_RIGHT:
    ldi b, $00A2        ; Xpixel = 162
    copy c, a        ; Ypixel = random, large asteroid
    andi c, $00FF
    ori c, $4000
    rjmp GET_SPAWN_LOC_END

GET_SPAWN_LOC_LEFT:
    ldi b, 0        ; Xpixel = 0
    copy c, a        ; Ypixel = random, large asteroid
    andi c, $00FF
    ori c, $4000
GET_SPAWN_LOC_END:
    ldi a, $FC00
    st a, b
    ldi a, $FC01
    st a, c
    pop c
    pop b
    pop a
    ret



