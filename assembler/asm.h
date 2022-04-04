#ifndef ASM_H_
#define ASM_H_

enum OP {
    NOP       = 0b00000000, // 0
    RJMP      = 0b00000001, // 1
    BEQ       = 0b00000010, // 2
    BNE       = 0b00000011, // 3
    BPL       = 0b00000100, // 4
    BMI       = 0b00000101, // 5
    BGE       = 0b00000111, // 6
    BLT       = 0b00001000, // 7
    LDI       = 0b00001001, // 8
    LD        = 0b00001010, // 9
    STI       = 0b00001011, // 10
    ST        = 0b00001100, // 11
    COPY      = 0b00001101, // 12
    ADD       = 0b00001111, // 13
    ADDI      = 0b00010000, // 14
    SUB       = 0b00010001, // 15
    SUBI      = 0b00010010, // 16
    CMP       = 0b00010011, // 17
    AND       = 0b00010100, // 18
    ANDI      = 0b00010101, // 19
    OR        = 0b00010111, // 20
    ORI       = 0b00011000, // 21
    PUSH      = 0b00011001, // 22
    POP       = 0b00011010, // 23
    ADC       = 0b00011011, // 24
    SBC       = 0b00011100, // 25
    MUL       = 0b00011101, // 26
    MULI      = 0b00011111, // 27
    MULS      = 0b00100000, // 28
    MULSI     = 0b00100001, // 29
    LSLS      = 0b00100010, // 30
    LSLR      = 0b00100011, // 31
    CMPI      = 0b00100100, // 32
    UNDEFINED = 0b11111111
};

enum REG {
    A = 0x0,
    B = 0x1,
    C = 0x2,
    D = 0x3,
    E = 0x4,
    F = 0x5,
    G = 0x6,
    H = 0x7,
    I = 0x8,
    J = 0x9,
    K = 0xA,
    L = 0xB,
    M = 0xC,
    N = 0xD,
    O = 0xE,
    P = 0xF,
};

int assemble(char filePath[20], char outputPath[20], int manual, int debug);
void parseLine(char** line, int* cmdc, char cmd[3][15]);
int translate(int* cmdc, char cmd[3][15]);
int getOpCode(char* text);
int getRegCode(char* text);

#endif // ASM_H_
