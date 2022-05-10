;init
LDI P,0
LDI O,0

MAIN:
    subr GET_JSTK_DIRECTION; get directon on a,b


    subr GET_CURRENT_POS ; get current positoin on c,d
    subr MOVE_SHIP ; get new coordinates of ship on c,d

    copy g,c ; show x direction on 7seg
    subr LONG_WAIT
    copy g,d ; show y direction on 7seg
    subr LONG_WAIT
    ; check what the new position is
    subr SET_NEW_POS ; set the new position with c,d

RJMP MAIN


MOVE_SHIP:
;----------
; Moves the spaceship with the coordinates retrived form the joystick 
; IN: a,b,c,d : a-jstk x, b - jstk y, c - ship x, d - ship y
; OUT: c,d - new position
;----------

push e
push f
push h

copy f,a
andi f,$7FFF; remove possible signed bit

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
    andi f,$8000; get possible signed bit
    cmpi f, $8000
    BEQ X_SIGNED
    add c,e
    RJMP X_NOT_SIGNED
X_SIGNED:
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
    ldi h,450
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
    add d,e
    rjmp Y_NOT_SIGNED
Y_SIGNED:
    sub d,e
Y_NOT_SIGNED:




pop h
pop f
pop e

ret



;----------
;   Returns a signed value which indicating direction 
;   the joystick is pointing and 
;   a value between 0-512 indicating how much 
; the joystick is pointing in a certain direction
;   IN --
;   OUT a - signed x value
;       b - signed y value
;
;----------
;the joystick goes between 0-1024
;0-512 indicates poiting down
;512 - 1024 indicates up

 
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

;----------
;Returns x,y,buttons from joystick to registers a and b
; in --
; out 
;   a - x coordinates
;   b - y coordinates
;   c - buttons
;----------
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


;-----
;waits for e * f nops
;in --
;out --
;-----
LONG_WAIT:
    push e
    push f
    LDI f, 500
    LDI e, 4000 
    SUBI e, 1
    CMPI e, 0
    BNE -2
    subi f, 1
    CMPI f, 0
    BNE -6
    pop f
    pop e

ret



WAIT:

    push e
    push f
    LDI f, 50
    LDI e, 4000 
    SUBI e, 1
    CMPI e, 0
    BNE -2
    subi f, 1
    CMPI f, 0
    BNE -6
    pop f
    pop e

ret
;----------
;Returns the current position of the spaceship
; in c,d - x,y pos
; out --
;
;----------
 

SET_NEW_POS:


    push a
    push b
    ;current position
    ; load x coords
    ldi a,$FC00
    st a,c
    ; load y coords
    
    ldi a,$FC01
    ;ld b,a
    ;andi b, #11111 000 11111111 ; get the sprite bits
    ;and d,b ; add sprite bits 
    st  a,d ; add the new position together with the sprite bits
    pop b 
    pop a

ret

GET_CURRENT_POS:
;----------
;Returns the current position of the spaceship
; in --
; out
;   c - x pos
;   d - y pos
;
;----------
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
