;init
LDI P,0
LDI O,0

MAIN:
    subr GET_JSTK_DIRECTION
    copy g,a ; show x direction on 7seg
    subr LONG_WAIT
    copy g,b ; show y direction on 7seg
    subr LONG_WAIT
RJMP MAIN


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
    LDI f, 2500
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


;GET_CURRENT_POS:
;;----------
;;Returns the current position of the spaceship
;; in --
;; out
;;   c - x pos
;;   b - y pos
;;
;;----------
;
;    push a
;    push b
;
;    ;current position
;    ; load x coords
;    ldi a,$FC00
;    ld c,a
;    ; load y coords
;    ldi a,$FC01
;    ld  d,c
;    andi d,1111100011111111;remove sprite bits
;    pop b
;    pop a
;
;ret
