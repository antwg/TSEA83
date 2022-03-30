#ifndef ASM_H_
#define ASM_H_

enum OP {
    NOP = 0x000,
    RJMP = 0x001,
    BEQ = 000010,
    BNE = 000011,
    BPL = 000100,
    BMI = 000101,
    BGE = 000111,
    BLT = 001000,
    LDI = 0x009,
    LD = 001010,
    STI = 001011,
    ST  = 001100,
    COPY = 001101,
    ADD = 001111,
    ADDI = 010000,
    SUB = 010001,
    SUBI = 010010,
    CMP = 010011,
    AND = 010100,
    ANDI = 010101,
    OR = 010111,
    ORI = 011000,
    PUSH = 011001,
    POP = 011010,
    ADC = 011011,
    SBC = 011100,
    MUL = 011101,
    MULI = 011111,
    MULS = 100000,
    MULSI = 100001,
    LSLS = 100010,
    LSLR = 100011,
    UNDEFINED = 0xFFF
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
