;====================== Useful Addresses =======================
; Addr below $0400 are in data memory
; Addr above $FC00 are in sprite memory
;
; $FC00 = x-coord for first sprite                              
; $FC01 = sprite (3 high) and y-coord (8 low) for first sprite  
;                                                               
; $0100 = x-coord part of move vector for first ship/asteroid   
; $0101 = y-coord part of move vector for first ship/asteroid   
;                                                               
; $0150 = Score                                                 
;                                                               
; $FC1F = Collision detection   
; 
; $0000 - $00FF = Stack                             
;                                                               
; Sprites):                                                      
; $2000 = Ship                  $A000 = Crashed ship            
; $4000 = First asteroid        $6000 = Second asteroid         
; $8000 = Third asteroid                                        
;===============================================================

; --------------------------------
; Initializes and starts the game
; In: -
; Out: -
; --------------------------------
MAIN:
    ;init
    LDI P,0
    LDI O,0

    ; Create ship
    ldi d, $FC00    ; x-pixel addr
    ldi e, $0054    ; x-pixel
    st d, e

    ldi d, $FC01    ; sprite and y-pixel addr
    ldi f, $2040     
    st d, f

    ; Set score to 0
    ldi d, $0150
    ldi f, 0
    st d, f

    ; Spawn asteroids
    ldi a, 1
    subr SPAWN_AST
    ldi a, 2
    subr SPAWN_AST
    ldi a, 3
    subr SPAWN_AST
    ldi a, 4
    subr SPAWN_AST
    ldi a, 5
    subr SPAWN_AST
    ldi a, 6
    subr SPAWN_AST
    ldi a, 7
    subr SPAWN_AST
    ldi a, 8
    subr SPAWN_AST

; --------------------------
; Main game loop
; --------------------------
MAIN_LOOP:
    ; Check if game over
    ldi a, $FC1F
    ld b, a
    cmpi b, $1234   ; 1234 = Game over
    beq GAME_OVER

    ; Show score
    ldi a, $0150
    ld n, a

    ; Move ship
    subr GET_JSTK_DIRECTION; get directon on a,b

    subr GET_CURRENT_POS ; get current positoin on c,d
    subr MOVE_SHIP ; get new coordinates of ship on c,d

    subr WAIT
    subr WAIT

    subr SET_NEW_POS ; set the new position with c,d

    ; Move asteroids
    ldi a, 1
    subr MOVE_AST
    ldi a, 2
    subr MOVE_AST
    ldi a, 3
    subr MOVE_AST
    ldi a, 4
    subr MOVE_AST
    ldi a, 5
    subr MOVE_AST
    ldi a, 6
    subr MOVE_AST
    ldi a, 7
    subr MOVE_AST
    ldi a, 8
    subr MOVE_AST

    ; Increase score
    ldi a, $0150
    ld b, a
    addi b, 1
    st a, b

    RJMP MAIN_LOOP


; ----------------------------------------------
; If game over, change sprite to destroyed ship
; and wait for restart button.
; In: - (Destroys a, b and d)
; Out: -
; ---------------------------------------------
GAME_OVER:
    ; Get ship sprite addr
    ldi d, $FC01 
    ld a, d
    andi a, $00ff   ; Save y-coordinate

    ; Change sprite to destroyed ship
    ldi b, $A000
    or a, b
    st d, a

    ; Reset collision detected
    ldi a, $FC1F
    ldi b, 0
    st a, b
    
GAME_OVER_LOOP:
    ; Check if any button pressed
    subr GET_JSTK_DATA
    andi c, #0001110000000000 ; mask out the buttons (remove x coords and enable)
    copy g, c
    cmpi c, 0
    bne GAME_OVER_RESTART
    rjmp GAME_OVER_LOOP

GAME_OVER_RESTART:
    rjmp MAIN


; --------------------------------------------------------------------
; Spawns an asteroid at its spawn locaion just outside of the screen.
; Also sets its direction.
;
; DATA_MEM(FCXX)      -> xpixel 8 bit (low)
; DATA_MEM(FCXX+1)    -> 3 bit sprite (high) + 8 bit ypixel (low) 
; 
; In: AST_NR(A)
; Out: -
; --------------------------------------------------------------------

SPAWN_AST:
    push a ; AST_NR
    push d ; Address
    push e ; x-pixel (8 low)
    push f ; sprite (3 high) and y-pixel (8 low)           

    ; Choose spawn location
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
    ldi e, 40           
    ldi f, 0            
    ldi b, 8            
    rjmp SPAWN_AST_END

SPAWN_AST_SEVEN: ; Top right
    ldi e, 120          
    ldi f, 0          
    ldi b, 7            
    rjmp SPAWN_AST_END

SPAWN_AST_SIX: ; Right top
    ldi e, 167          
    ldi f, 90           
    ldi b, 6            
    rjmp SPAWN_AST_END

SPAWN_AST_FIVE: ; Right bottom
    ldi e, 167          
    ldi f, 30           
    ldi b, 5            
    rjmp SPAWN_AST_END

SPAWN_AST_FOUR: ; Bottom Right
    ldi e, 120          
    ldi f, 127          
    ldi b, 4            
    rjmp SPAWN_AST_END

SPAWN_AST_THREE: ; Bottom left
    ldi e, 40           
    ldi f, 127          
    ldi b, 3            
    rjmp SPAWN_AST_END

SPAWN_AST_TWO: ; Left on same height as ship
    ldi d, $FC01    
    ldi e, 0          
    ld f, d           
    andi f, $00FF
    ldi b, 2            
    rjmp SPAWN_AST_END

SPAWN_AST_ONE: ; Top on same width as ship
    ldi d, $FC00
    ld e, d            
    ldi f, 0           
    ldi b, 1            

SPAWN_AST_END:
    subr SET_AST_DIR
    subr GET_AST_COLOR   ; Get a random color of asteroid (in B) and apply
    or f, b              ; add which asteroid to f reg

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

; ------------------------------------
; Gets a random color for an asteroid
; In: AST_NR(A)
; Out: Sprite(B)
; ------------------------------------
GET_AST_COLOR:
    push a
    push c

    ; Get random num and move to C
    push a             
    subr RAND_NUM_GEN
    copy c, a
    pop a

    ; Choose random color
    andi c, $0003
    cmpi c, 0
    beq GET_AST_COLOR_ONE
    cmpi c, 1
    beq GET_AST_COLOR_TWO
    cmpi c, 2
    beq GET_AST_COLOR_THREE

GET_AST_COLOR_THREE:
    ldi b, $8000
    rjmp GET_AST_SIZE_END
GET_AST_COLOR_TWO:
    ldi b, $6000
    rjmp GET_AST_SIZE_END
GET_AST_COLOR_ONE:
    ldi b, $4000
    rjmp GET_AST_SIZE_END
GET_AST_SIZE_END:
    pop c
    pop a
    ret


; ----------------------------
; Returns a pseudorandom num
; between 0 and FFFF in Reg A
; Uses Reg G to store progress
; In: (G)
; Out: A
; ----------------------------
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

; ----------------------------------------------------
; Asteroids direction is saved at $(0100 + 2 * AST_NR)
; ex. AST_NR = 2 => $F4: x_dir
;                => $F5: y_dir
; In: AST_DIR(B), AST_NR(A)
; Out: -
; ----------------------------------------------------
SET_AST_DIR:
    push c
    push d
    push e
    push f
    push a 
    push b

    ; Get addr in data_mem for direction
    ldi c, $0100
    ldi d, $0101
    lsls a          
    add c, a
    add d, a
    lsrs a          
;
    ; Decode AST_DIR
    cmpi b, 1               
    beq SET_AST_DIR_ONE
    cmpi b, 2               
    beq SET_AST_DIR_TWO
    cmpi b, 3               
    beq SET_AST_DIR_THREE
    cmpi b, 4              
    beq SET_AST_DIR_FOUR
    cmpi b, 5              
    beq SET_AST_DIR_FIVE
    cmpi b, 6              
    beq SET_AST_DIR_SIX
    cmpi b, 7              
    beq SET_AST_DIR_SEVEN
    ; else eight

SET_AST_DIR_EIGHT:
    ldi e, 1        ; x-dir
    ldi f, 2        ; y-dir
    rjmp SET_AST_DIR_END
SET_AST_DIR_SEVEN:
    ldi e, -2        
    ldi f, 1
    rjmp SET_AST_DIR_END        
SET_AST_DIR_SIX:        ; 5 and 6 switched 
    ldi e, -1      
    ldi f, -2
    rjmp SET_AST_DIR_END   
SET_AST_DIR_FIVE:
    ldi e, -2      
    ldi f, 1
    rjmp SET_AST_DIR_END  
SET_AST_DIR_FOUR:
    ldi e, -1       
    ldi f, -2
    rjmp SET_AST_DIR_END  
SET_AST_DIR_THREE:
    ldi e, 2       
    ldi f, -1
    rjmp SET_AST_DIR_END 
SET_AST_DIR_TWO:        ; 2 and 1 switched
    ldi e, 3       
    ldi f, 0
    rjmp SET_AST_DIR_END     
SET_AST_DIR_ONE:
    ldi e, 0        
    ldi f, 3        
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


; ----------------------------------------
; Updates the position of ast with AST_NR
; Reads direction from data mem.
; In: AST_NR(A)
; Out: -
; ----------------------------------------
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

    lsls a          
    add c, a
    add d, a
    ld e, c         ; x-part of move vector
    ld f, d         ; y-part of move vector

    ; Read curr position and update
    ldi c, $FC00
    ldi d, $FC01
    add c, a        ; Add AST_NR
    add d, a

    ld g, c         ; Curr x-pos
    ld h, d         ; Curr y-pos
    add g, e        ; New x-pos
    add h, f        ; New y-pos

    lsrs a
    subr IN_BOUNDS
    pop a
    pop h
    pop g
    pop f
    pop e
    pop d
    pop c
    ret


; -------------------------------------------------
; Checks if an asteroid is in bounds,
; If it is: do nothing, else respawn it in bounds.
; In: A(AST_NR), G(x-coord), H(y-coord)
; Out: -
; -------------------------------------------------
IN_BOUNDS:
    push f
    ; Check right edge
    cmpi g, 170
    bpl IN_BOUNDS_FALSE

    ; Check bottom edge
    copy f, h
    andi f, $00ff
    copy i, a
    cmpi f, 130
    bpl IN_BOUNDS_FALSE

IN_BOUNDS_TRUE:
    ; Store new pos
    st c, g
    st d, h
    rjmp IN_BOUNDS_END

IN_BOUNDS_FALSE:            
    subr SPAWN_AST

IN_BOUNDS_END:
    pop f
    ret


; --------------------------------------------------------------------
; Moves the spaceship with the coordinates retrived form the joystick 
; In: a,b,c,d : a-jstk x, b - jstk y, c - ship x, d - ship y
; Oot: c,d - new position
; --------------------------------------------------------------------
MOVE_SHIP:
    push e
    push f
    push h

    copy f,a
    andi d, $00FF ; remove sprite bits (gets set again later)
    andi f,$7FFF ; remove possible signed bit

FIRST_SPEED_X:
    ldi h,450
    ldi e,3
    sub h,f  
    blt SPEED_DONE_X
SECOND_SPEED_X:
    ldi h,300
    ldi e,2
    sub h,f  
    blt SPEED_DONE_X

THIRD_SPEED_X:
    ldi h,150
    ldi e,1
    sub h,f  
    blt SPEED_DONE_X
    ldi e,0 ; jstk movement to low dont move

SPEED_DONE_X:
    ;do smth
    copy f,a
    andi f, $8000; get possible signed bit
    cmpi f, $8000

    BEQ X_SIGNED
    ; if result will be negative then ignore otherwise subtract
    copy f,c
    copy h,f 
    add h,e 
    subi h,165 
    bge X_NOT_SIGNED; if h is larger than 0FF we dont want to do anything

    add c,e
    RJMP X_NOT_SIGNED
X_SIGNED:
    ; if result will be negative then ignore otherwise subtract
    copy f,c
    copy h,f
    subi h,1
    sub h,e 
    blt X_NOT_SIGNED; if h is larger than there was overflow
    sub c,e
    
; reset for Y coordinates
X_NOT_SIGNED:
    copy f,b
    andi f,$7FFF; remove possible signed bit
    
FIRST_SPEED_Y:
    ldi h,450
    ldi e,3
    sub h,f  
    blt SPEED_DONE_Y
SECOND_SPEED_Y:
    ldi h,300
    ldi e,2
    sub h,f  
    blt SPEED_DONE_Y

THIRD_SPEED_Y:
    ldi h,100
    ldi e,1
    sub h,f  
    blt SPEED_DONE_Y

    ldi e,0 ; jstk movement to low dont move
SPEED_DONE_Y:
    ;do smth

    copy f,b
    andi f,$8000; get possible signed bit
    cmpi f,$8000
    BEQ Y_SIGNED

    copy f,d
    copy h,f
    subi h,1

    sub h,e 

    blt Y_NOT_SIGNED; if h is larger than 0FF we dont want to do anything

    sub d,e
    rjmp Y_NOT_SIGNED
Y_SIGNED:
    copy f,d
    copy h,f 
    add h,e 
    subi h,125

    bge Y_NOT_SIGNED; if h is larger than there was overflow

    add d,e

Y_NOT_SIGNED:
    pop h
    pop f
    pop e

    ret



;-----------------------------------------------------
; Returns a signed value which indicating direction 
; the joystick is pointing and 
; a value between 0-512 indicating how much 
; the joystick is pointing in a certain direction
; IN --
; OUT a - signed x value
;     b - signed y value
; 
; the joystick goes between 0-1024
; 0-512 indicates poiting down
; 512 - 1024 indicates up
;-----------------------------------------------------
GET_JSTK_DIRECTION:
    push d
    subr GET_JSTK_DATA
    copy c,a
    subi c,512
    bge X_GREATER_THAN 
    
    X_LESS_THAN:
    ; make sure a is in the value of 0-512 where 0 is closest to the middle
    ldi d,512
    sub d,a  
    copy a,d
    ori a,#1000000000000000 ;set the signed bit
    RJMP X_DONE

X_GREATER_THAN:
    subi a,512; remove 512 to keep the value between 0-512

X_DONE:
    copy c,b
    subi c,512
    bge Y_GREATER_THAN

Y_LESS_THAN:
    ; make sure the value is in the value of 0-512 where 0 is closest to the middle
    ldi d,512
    sub d,b  
    copy b,d
    ori b,#1000000000000000 ;set the signed bit

    rjmp DONE
    
Y_GREATER_THAN:
    subi b,512

DONE:
    pop d
    ret

;-------------------------------------------------------
;Returns x,y,buttons from joystick to registers a and b
; in --
; out 
;   a - x coordinates
;   b - y coordinates
;   c - buttons
;-------------------------------------------------------
GET_JSTK_DATA:
    LDI P, 32768 ; load enable bit 1000000000000000
    subr WAIT
    copy a,p ; save x,btns to a
    andi a,#0000001111111111; mask out x coordiantes, (remove button press and enable) 
    copy b,o ; get the y coordinates
    copy c,p; save x,btns to c
    andi c,#0001110000000000 ; mask out the buttons (remove x coords and enable)
    ANDI p, 32767 ; disable joystick 0111111111111111
    ret


;--------------------------
; Waits for a certain time
; dependant on the score.
; In: --
; Out: --
;--------------------------
WAIT:
    push e
    push f
    push c
    push d
    LDI f, 50
WAIT_OUTER_LOOP:
    ; Remove score from 2500 to shorten wait as score increases
    ldi d, $0150  
    ld c, d
    LDI e, 2500
    sub e, c
WAIT_LOOP: 
    SUBI e, 1
    CMPI e, 0
    BNE WAIT_LOOP
    subi f, 1
    CMPI f, 0
    BNE WAIT_OUTER_LOOP
    pop c
    pop d
    pop f
    pop e
    ret

; -------------------------------------------
; sets the current position of the spaceship
; In: c,d - x,y pos
; Out: -
; -------------------------------------------
SET_NEW_POS:
    push a
    push b
    ;current position
    ; load x coords
    ldi a,$FC00
    ;ldi c, $0022
    st a,c
    ; load y coords

    ldi a,$FC01
    ;ld b,a
    ori d,#0010000000000000 ; set the ship bit
    ;and d,b ; add sprite bits 
    ;ldi d, $0022
    st  a,d ; add the new position together with the sprite bits
    pop b 
    pop a
    ret

; ----------------------------------------------
; Returns the current position of the spaceship
; in --
; out c - x pos
;     d - y pos
; ----------------------------------------------
GET_CURRENT_POS:
    push a

    ;current position
    ; load x coords
    ldi a,$FC00
    ld c,a
    ; load y coords
    ldi a,$FC01
    ld  d,a
    andi d,#1111100011111111;remove sprite bits
    pop a
    ret
