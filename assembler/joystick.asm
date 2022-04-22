;F0 -> SS 
;F1 -> MOSI binärt och så att man kan 
;F2 -> MISO
;F3  -> SCLK

; sclk updates after 2000 clock cycles
; meaning sclk rises every 4000 clock cycles
; getting the values from the joystick in the middle of these is probably best 


; so the best way might be to wait fo SCLK to go high and then
; wait some cycles and get the contents, then wait fo SCLK again
; this way we will not become unsyncronized with the joystick

;joystick start:
LDI c,2 ; set a mosi bit xxxx0010 this is later cleared so that the remaning sent is 0
LDI d,40
LDI e,10
LDI f,0
;joystick_loop:

LDI a,8 ;xxxx1000
ORI p,1 ; set SS high, xxxx0001

;LOOP_START:
LDI a,8 ;xxxx1000 mask for SCLK bit 
AND a,p ; mask out SCLK
CMPI a,4 ; check if SCLK was high
brne LOOP_START
; wait for a couple of cycles to make sure joystick has time to transmit
LDI a,200 ; load with the wait amount
;LOOP_START2:
SUBI a,1
CMPI a,0
brne LOOP_START2 ; when looped "a" amount then stop  

LDI b,4 ; xxxx0100 ; mask for MISO bit (joystick output)
AND b,p ; now we get the bit from the joystick

LSLR b,b ; move the MISO bit to the least significant bit
LSLR b,b


ANDI p,65531 ; clear the MOSI bit  1111111111111011 = 65,531 
ORI p,c ; set the mosi bit to the value in c
ANDI c,0; the first of the 40 bits send to the joystick should be 1 and the rest 0 
SUBI d,1 ; all bits counter

CMPI e,0
breq e_done ; if we have revied the bits for x then skip
subi e,1 ; x bit counter 
OR f,b;
LSLS f,f ; move the  bits for the x 
e_done:

brne joystick_loop ; when b is not 0 jump to the start
; all bits have been recived so set ss low again
ANDI p,65534 ; set SS low, xxxx1110 

