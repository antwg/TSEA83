    ;ldi a, 0
    ;ldi b, $FC00
    ;ldi c, $FC01
    nop
    subr SPAWN_AST
    ldi a, 0

START:
    subr MOVE_AST
    subr TENTH_TIMER

    ;ld d, b
    ;addi d, 1
    ;st b, d
    ;ld d, c
    ;addi d, 1
    ;st c, d
    
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
; Spawns an asteroid at a random locaion
; just outside of the screen. (top, left, ...).
; Also sets direction opposite of spawn, eg. if
; spawn on left side, dir = right
;
; DATA_MEM(FCXX)      -> xpixel 8 bit (low)
; DATA_MEM(FCXX+1)    -> 3 bit sprite (high) + 8 bit ypixel (low) 
; 
; In: AST_NR(A)
; Out: -
; --------------------------

SPAWN_AST:
    push d ; Random number
    push e ; xpixel (8 low)
    push f ; which sprite (3 high) and ypixel (8 low)

    push a
    subr RAND_NUM_GEN               ; Random number always returned to Reg(a)
    copy d, a                       ; Need to move to another reg to save AST_NR
    pop a               

    ; Choose left/right/bottom/top
    copy e, d
    andi e, $0003
    cmpi e, 0
    beq SPAWN_AST_LEFT
    cmpi e, 1
    beq SPAWN_AST_RIGHT
    cmpi e, 2
    beq SPAWN_AST_BOTTOM

SPAWN_AST_TOP:
    ldi e, 80           ; Xpixel = 80
    ldi f, $0000        ; Ypixel = 0
    ldi b, 3            ; Set dir down
    rjmp SPAWN_AST_END

SPAWN_AST_BOTTOM:
    ldi e, 80           ; Xpixel = 80
    ldi f, 130          ; Ypixel = 130
    ldi b, 1            ; Set dir up
    rjmp SPAWN_AST_END

SPAWN_AST_RIGHT:
    ldi e, $00A2        ; Xpixel = 162
    ldi f, 65           ; Ypixel = 65
    ldi b, 2            ; Set dir left
    rjmp SPAWN_AST_END

SPAWN_AST_LEFT:
    ldi e, 0            ; Xpixel = 0
    ldi f, 65           ; Ypixel = 65
    ldi b, 0            ; Set dir right

SPAWN_AST_END:
    subr GET_AST_SIZE   ; Get a random size of asteroid and apply
    or f, b

    mulsi a, 2           ; Store xpixel
    ldi d, $FC00
    add d, a
    st d, e

    ldi d, $FC01        ; Store ypixel and asteroid type
    add d, a
    st d, f

    subr SET_AST_DIR

    pop f
    pop e
    pop d
    ret

; --------------------------
; Gets a random size for an asteroid
; In: AST_NR(A)
; Out: Sprite(B)
; --------------------------
GET_AST_SIZE:
    push c

    ; Get random num and move to C
    push a             
    subr RAND_NUM_GEN
    copy c, a
    pop a

    ; Choose random size
    andi a, $0003
    cmpi a, 0
    beq GET_AST_SIZE_LARGE
    cmpi a, 1
    beq GET_AST_SIZE_MEDIUM
    cmpi a, 2
    beq GET_AST_SIZE_SMALL

GET_AST_SIZE_SMALL:
    ldi b, $8000
    rjmp GET_AST_SIZE_END
GET_AST_SIZE_MEDIUM:
    ldi b, $6000
    rjmp GET_AST_SIZE_END
GET_AST_SIZE_LARGE:
    ldi b, $4000
    rjmp GET_AST_SIZE_END
GET_AST_SIZE_END:
    pop c
    ret


; --------------------------
; Asteroids direction is saved at $(00F0 + 2 * AST_NR)
; ex. AST_NR = 2 => $F4: x_dir
;                => $F5: y_dir
; In: AST_DIR(B), AST_NR(A)
; --------------------------
SET_AST_DIR:
    push c
    push d
    push e
    push f

    ; Get position in data_mem
    ldi c, $00F0
    ldi d, $00F1
    lsls a          ; Mult by 2
    add c, a
    add d, a
    lsrs a          ; Reset

    ; Decode AST_DIR
    cmpi b, 0               ; Right 
    beq SET_AST_DIR_RIGHT
    cmpi b, 1               ; Up
    beq SET_AST_DIR_UP
    cmpi b, 2               ; Left
    beq SET_AST_DIR_LEFT
    ; else down

SET_AST_DIR_DOWN:
    ldi e, 0        ; x-dir
    ldi f, 1        ; y-dir
SET_AST_DIR_RIGHT:
    ldi e, 1        
    ldi f, 0        
SET_AST_DIR_LEFT:
    ldi e, -1       
    ldi f, 0        
SET_AST_DIR_UP:
    ldi e, 0        
    ldi f, -1        
SET_AST_DIR_END:
    st c, e
    st d, f

    pop f
    pop e
    pop d
    pop c
    ret

; --------------------------
; Updates the position of ast with AST_NR
; Reads direction from data mem.
; In: AST_NR(A)
; Out: A (Nondestructive)
; --------------------------
MOVE_AST:
    push c
    push d
    push e
    push f
    push g
    push h

    ; Get position addr in data_mem
    ldi c, $00F0
    ldi d, $00F1
    lsls a          ; Mult by 2
    add c, a
    add d, a
    ld e, c         ; Move "vector" in x-dir
    ld f, d         ; Move "vector" in y-dir

    ; Read curr position and update
    ldi c, $FC00
    ldi d, $FC01
    add c, a
    add d, a
    ld g, c         ; Curr x-pos
    ld h, d         ; Curr y-pos
    add g, e        ; New x-pos
    add h, d        ; New y-pos
    
    ; Store new pos
    st c, g
    st d, h

MOVE_AST_END:
    lsrs a
    pop h
    pop g
    pop f
    pop e
    pop d
    pop c
    ret

