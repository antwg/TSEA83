
;ldi a, 0
;subr SPAWN_AST
;ldi a, 1
;subr SPAWN_AST
ldi a, 2
subr SPAWN_AST
;ldi a, 3
;subr SPAWN_AST
;ldi a, 4
;subr SPAWN_AST
;ldi a, 5
;subr SPAWN_AST
;ldi a, 6
;subr SPAWN_AST
;ldi a, 7
;subr SPAWN_AST
;ldi a, 8
;subr SPAWN_AST

LOOP:
    ;ldi a, 0
    ;subr MOVE_AST

    ;ldi a, 1
    ;subr MOVE_AST
;
    ldi a, 2
    subr MOVE_AST
;
    ;ldi a, 3
    ;subr MOVE_AST
;
    ;ldi a, 4
    ;subr MOVE_AST
;
    ;ldi a, 5
    ;subr MOVE_AST
;
    ;ldi a, 6
    ;subr MOVE_AST
;
    ;ldi a, 7
    ;subr MOVE_AST
;
    ;ldi a, 8
    ;subr MOVE_AST

    subr TENTH_TIMER
    subr TENTH_TIMER
    subr TENTH_TIMER
    subr TENTH_TIMER
    subr TENTH_TIMER
    RJMP LOOP



; --------------------------
; ~ A 1 ms delay
; In: -
; Out: -
; --------------------------
MS_TIMER:
    push b
    push c
    ldi b, 249
    ldi c, 10;100
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
    push a
    push d ; Random number
    push e ; xpixel (8 low)
    push f ; which sprite (3 high) and ypixel (8 low)

    ;push a
    ;subr RAND_NUM_GEN               ; Random number always returned to Reg(a)
    ;copy d, a                       ; Need to move to another reg to save AST_NR
    ;pop a             

    ; Choose left/right/bottom/top
    cmpi a, 1
    beq SPAWN_AST_ONE
    cmpi a, 2
    beq SPAWN_AST_TWO
    cmpi a, 3
    beq SPAWN_AST_THREE
    cmpi a, 4
    beq SPAWN_AST_FOUR
    cmpi a, 5
    beq SPAWN_AST_FIVE
    cmpi a, 6
    beq SPAWN_AST_SIX
    cmpi a, 7
    beq SPAWN_AST_SEVEN

SPAWN_AST_EIGHT: ; top left
    ldi e, 40           ; Xpixel = 80
    ldi f, 0            ; Ypixel = 0
    ldi b, 8            ; Set dir up
    rjmp SPAWN_AST_END

SPAWN_AST_SEVEN: ; Top right
    ldi e, 120           ; Xpixel = 80
    ldi f, 0          ; Ypixel = 130
    ldi b, 7            ; Set dir up
    rjmp SPAWN_AST_END

SPAWN_AST_SIX: ; Right top
    ldi e, 167        ; Xpixel = 162
    ldi f, 90           ; Ypixel = 65
    ldi b, 6            ; Set dir left
    rjmp SPAWN_AST_END

SPAWN_AST_FIVE: ; Right bottom
    ldi e, 167            ; Xpixel = 0
    ldi f, 30           ; Ypixel = 65
    ldi b, 5            ; Set dir right
    rjmp SPAWN_AST_END

SPAWN_AST_FOUR: ; Bottom Right
    ldi e, 120            ; Xpixel = 0
    ldi f, 127           ; Ypixel = 65
    ldi b, 4            ; Set dir left
    rjmp SPAWN_AST_END

SPAWN_AST_THREE: ; Bottom left
    ldi e, 40            ; Xpixel = 0
    ldi f, 127           ; Ypixel = 65
    ldi b, 3            ; Set dir right
    rjmp SPAWN_AST_END

SPAWN_AST_TWO: ; Left bottom
    ldi e, 0            ; Xpixel = 0
    ldi f, 30           ; Ypixel = 65
    ldi b, 2            ; Set dir right
    rjmp SPAWN_AST_END

SPAWN_AST_ONE: ; Left top
    ldi e, 0            ; Xpixel = 0
    ldi f, 90           ; Ypixel = 65
    ldi b, 1            ; Set dir right

SPAWN_AST_END:
    subr SET_AST_DIR
    ldi b, $8000; subr GET_AST_SIZE   ; Get a random size of asteroid (in B) and apply
    or f, b             ; add which asteroid to f reg

    lsls a 
    
    ; Store xpixel
    ldi d, $FC00
    add d, a
    st d, e

    ; Store ypixel and asteroid type
    ldi d, $FC01
    add d, a
    st d, f

    pop f
    pop e
    pop d
    pop a
    ret

; --------------------------
; Gets a random size for an asteroid
; In: AST_NR(A)
; Out: Sprite(B)
; --------------------------
GET_AST_SIZE:
    push a
    push c

    ; Get random num and move to C
    push a             
    subr RAND_NUM_GEN
    copy c, a
    pop a

    ; Choose random size
    andi c, $0003
    cmpi c, 0
    beq GET_AST_SIZE_LARGE
    cmpi c, 1
    beq GET_AST_SIZE_MEDIUM
    cmpi c, 2
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
    pop a
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
; Asteroids direction is saved at $(0100 + 2 * AST_NR)
; ex. AST_NR = 2 => $F4: x_dir
;                => $F5: y_dir
; In: AST_DIR(B), AST_NR(A)
; --------------------------
SET_AST_DIR:
    push c
    push d
    push e
    push f
    push a 
    push b

    ; Get position in data_mem for direction
    ldi c, $0100
    ldi d, $0101
    lsls a          ; Mult by 2
    add c, a
    add d, a
    lsrs a          ; Reset
;
    ;; Decode AST_DIR
    ;cmpi b, 1               
    ;beq SET_AST_DIR_ONE
    ;cmpi b, 2               
    ;beq SET_AST_DIR_TWO
    ;cmpi b, 3               
    ;beq SET_AST_DIR_THREE
    ;cmpi b, 4              
    ;beq SET_AST_DIR_FOUR
    ;cmpi b, 5              
    ;beq SET_AST_DIR_FIVE
    ;cmpi b, 6              
    ;beq SET_AST_DIR_SIX
    ;cmpi b, 7              
    ;beq SET_AST_DIR_SEVEN
    ; else down

;SET_AST_DIR_EIGHT:
;    ldi e, 1        ; x-dir
;    ldi f, 2        ; y-dir
;    rjmp SET_AST_DIR_END
;SET_AST_DIR_SEVEN:
;    ldi e, -2        
;    ldi f, 1
;    rjmp SET_AST_DIR_END        
;SET_AST_DIR_SIX:        ; 5 and 6 switched for some cursed reason
;    ldi e, -1      
;    ldi f, -2
;    rjmp SET_AST_DIR_END   
;SET_AST_DIR_FIVE:
;    ldi e, -2      
;    ldi f, 1
;    rjmp SET_AST_DIR_END  
;SET_AST_DIR_FOUR:
    ;ldi e, -1       
    ;ldi f, -2
;    rjmp SET_AST_DIR_END  
;SET_AST_DIR_THREE:
;    ldi e, 2       
;    ldi f, -1
;    rjmp SET_AST_DIR_END 
;SET_AST_DIR_TWO:        ; 2 and 1 switched
    ldi e, 3       
    ldi f, 2
;    rjmp SET_AST_DIR_END     
;SET_AST_DIR_ONE:
    ;ldi e, 2        
    ;ldi f, -2        
SET_AST_DIR_END:
    st c, e
    st d, f

    pop b
    pop a
    pop f
    pop e
    pop d
    pop c
    ret


; --------------------------
; Updates the position of ast with AST_NR
; Reads direction from data mem.
; In: AST_NR(A)
; Out: -
; --------------------------
MOVE_AST:
    push c
    push d
    push e
    push f
    push g
    push h
    push a

    ; Get position addr in data_mem
    ldi c, $0100
    ldi d, $0101

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
    add h, f        ; New y-pos

    lsrs a
    subr IN_BOUNDS

    ; Store new pos
    st c, g
    st d, h

MOVE_AST_END:
    pop a
    pop h
    pop g
    pop f
    pop e
    pop d
    pop c
    ret


; --------------------------
; Checks if an asteroid is in bounds,
; If it is: do nothing, else erspawn it in bounds.
; In: A(AST_NR), G(x-coord), H(y-coord)
; --------------------------
IN_BOUNDS:
    push f

    ;cmpi g, 160
    ;bpl IN_BOUNDS_FALSE
    copy f, h
    andi f, $00ff
    copy i, a
    
    cmpi f, 80
    bpl IN_BOUNDS_FALSE
    rjmp IN_BOUNDS_END

IN_BOUNDS_FALSE:
    ;push d
    ;push e
    
    ; Reset pos
    ;lsls a     
    ;ldi f, 0      
    ;ldi d, $FC00
    ;add d, a
    ;st d, f
    ;ldi d, $FC01       
    ;add d, a
    ;st d, f
    ;lsrs a              
    subr SPAWN_AST
    
    ;pop e
    ;pop d
IN_BOUNDS_END:
    pop f
    ret


