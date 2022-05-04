



GET_JOYSTICK_DATA:
;----------
;Returns x,y,buttons from joystick to registers a and b
; in --
; out 
;   a - x coordinates
;   b - y coordinates
;   c - buttons
;----------

copy p,a
andi a,0000001111111111; mask out x coordiantes, (remove button press and enable) 
copy o,b ; get the y coordinates
copy p,c
andi 0001110000000000 ; mask out the buttons (remove x coords and enable)
ret

GET_CURRENT_POS:
;----------
;Returns the current position of the spaceship
; in --
; out
;   c - x pos
;   b - y pos
;
;----------

push a
push b

;current position
; load x coords
ldi a,$FC00
ld c,a
; load y coords
ldi a,$FC01
ld  d,c
andi d,1111100011111111;remove sprite bits
pop b
pop a


ret

MOVE_SHIP:
;----------
; Moves the spaceship with the coordinates retrived form the joystick 
; IN: new joystick data 
; OUT: --
;----------

push a
push b
push c
push d
; get the joystick data on A and B
; and the current positoin on C and D
subr GET_JOYSTICK_DATA
subr GET_CURRENT_POS

;scale down joystick data and add it to the current position
; might work, however using shifts intstead of div will result in 
; a loss of precisoin of the joystick data



pop d
pop c
pop b
pop a
ret

