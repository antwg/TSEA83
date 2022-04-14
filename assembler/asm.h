#ifndef ASM_H_
#define ASM_H_

enum OP {
    NOP       = 0x00,
    RJMP      = 0x01,
    BEQ       = 0x02,
    BNE       = 0x03,
    BPL       = 0x04,
    BMI       = 0x05,
    BGE       = 0x06,
    BLT       = 0x07,
    LDI       = 0x08,
    LD        = 0x09,
    STI       = 0x0A,
    ST        = 0x0B,
    COPY      = 0x0C,
    ADD       = 0x0D,
    ADDI      = 0x0E,
    SUB       = 0x0F,
    SUBI      = 0x10,
    CMP       = 0x11,
    CMPI      = 0x12,
    AND       = 0x13,
    ANDI      = 0x14,
    OR        = 0x15,
    ORI       = 0x16,
    PUSH      = 0x17,
    POP       = 0x18,
    ADC       = 0x19,
    SBC       = 0x1A,
    MUL       = 0x1B,
    MULI      = 0x1C,
    MULS      = 0x1D,
    MULSI     = 0x1E,
    LSLS      = 0x1F,
    LSRS      = 0x20,
    UNDEFINED = 0xFF
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

int assemble(char filePath[40], char outputPath[40], int manual, int debug);
void parseLine(char** line, int* cmdc, char cmd[3][40]);
int getOpCode(char* text);
int getRegCode(char* text);
void printHelp();

#endif // ASM_H_
