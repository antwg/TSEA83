#ifndef ASM_H_
#define ASM_H_

enum OP {
    NOP       = 0b000000, // 0
    RJMP      = 0b000001, // 1
    BEQ       = 0b000010, // 2
    BNE       = 0b000011, // 3
    BPL       = 0b000100, // 4
    BMI       = 0b000101, // 5
    BGE       = 0b000111, // 6
    BLT       = 0b001000, // 7
    LDI       = 0b001001, // 8
    LD        = 0b001010, // 9
    STI       = 0b001011, // 10
    ST        = 0b001100, // 11
    COPY      = 0b001101, // 12
    ADD       = 0b001111, // 13
    ADDI      = 0b010000, // 14
    SUB       = 0b010001, // 15
    SUBI      = 0b010010, // 16
    CMP       = 0b010011, // 17
    AND       = 0b010100, // 18
    ANDI      = 0b010101, // 19
    OR        = 0b010111, // 20
    ORI       = 0b011000, // 21
    PUSH      = 0b011001, // 22
    POP       = 0b011010, // 23
    ADC       = 0b011011, // 24
    SBC       = 0b011100, // 25
    MUL       = 0b011101, // 26
    MULI      = 0b011111, // 27
    MULS      = 0b100000, // 28
    MULSI     = 0b100001, // 29
    LSLS      = 0b100010, // 30
    LSLR      = 0b100011, // 31
    CMPI      = 0b100100, // 32
    UNDEFINED = 0b111111
};

enum REG {
    A = 0,
    B = 1,
    C = 2,
    D = 3,
    E = 4,
    F = 5,
    G = 6,
    H = 7,
    I = 8,
    J = 9,
    K = 10,
    L = 11,
    M = 12,
    N = 13,
    O = 14,
    P = 15,
};

int assemble(char filePath[20], char outputPath[20]);
void parseLine(char** line, int* cmdc, char cmd[3][15]);
int translate(int* cmdc, char cmd[3][15]);
int getOpCode(char* text);
int getRegCode(char* text);

#endif // ASM_H_
