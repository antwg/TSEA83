    pusr
    ldi a, 10
    ldi b, 4

    sub a, b        ; a = 6
    addi a, 2       ; a = 8
    subi b, 2       ; b = 2
    add a, b        ; a = 10

    ; --- test shifting and multiplying ---
    lsrs a          ; a = 5
    muli, a, 3      ; a = 15
    lsls b          ; b = 4
    mul a, b        ; a = 60
    mulsi a, -1     ; a = -60 

    ; --- test storing and reading ---
    st b, a         ; store a = -60 on addr b = 4
    ldi a, 0        ; a = 0
    ld a, b         ; a = -60

    ; --- test and or ---
    andi a, 7       ; a = 4
    ldi b, 8
    or a, b         ; a = 12  
    ori a, 16       ; a = 28
    and a, b        ; a = 8

    ; --- test muls ---
    muls a, a       ; a = 64
    
    ; --- test beq ---
    cmpi a, 64
    beq 2           ; Should branch
    ldi a, 0
    addi a, 6       ; a = 70
    cmpi a, 63 
    beq 2           ; should not branch
    addi a, 2       ; a = 72

    ; --- test bne ---
    cmpi a, 2 
    bne 2           ; should branch
    ldi a, 0
    cmp a, a 
    bne 2           ; should not branch
    addi a, 2       ; a = 74

    ; --- test bpl ---
    cmpi a, 1
    bpl 2           ; should branch
    ldi a, 0
    cmpi a, 100
    bpl 2           ; should not branch
    addi a, 2       ; a = 76

    ; --- test bmi ---
    cmpi a, 100
    bmi 2           ; should branch
    ldi a, 0
    cmpi a, 1
    bmi 2           ; should not branch
    addi a, 2       ; a = 78

    ; --- test bge ---
    cmpi a, 10      
    bge 2           ; should branch
    ldi a, 0
    cmp a, a 
    bge 2           ; should branch
    ldi a, 0
    cmpi a, 100     
    bge 2           ; should not branch
    addi a, 2       ; a = 80

    ; --- test blt ---
    cmpi a, 100
    blt 2           ; should branch
    ldi a, 0
    cmp a, a 
    blt 2           ; should not branch
    addi a, 2       ; a = 82
    cmpi a, 4
    blt 2           ; should not branch
    addi a, 2       ; a = 84

    ; Make output more manageable 
    lsrs a          ; a = 42
    lsrs a          ; a = 21
    subi a, 16      ; a = 5

    ; Test PUSH/POOP
    ldi b, 10
    push a
    push b
    ldi a, 0
    pop b
    pop a
    cmp a,a
    posr


LOOP:
    nop
    rjmp LOOP
