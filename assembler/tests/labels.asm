    ;;  commoeont
    ;;  comment


; above 2 lines are intentionally left empty

rjmp FIRST                      ; 0
LDI a,1                         ; 1 should be skipped

FIRST:                          ; 2 label
    LDI a,2                     ; 2
    rjmp LOOP                   ; 3

ldi a,3                         ; 4
rjmp LOOP

SECOND:
    rjmp FIRST

LOOP:                           ; 5 lbl
    nop                         ; 5
    rjmp LOOP                   ; 6
