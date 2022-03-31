#include "asm.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

// Assumes little endian
void printBits(size_t const size, void const * const ptr)
{
    unsigned char *b = (unsigned char*) ptr;
    unsigned char byte;
    int i, j;

    for (i = 0; i < size; i++) {
        for (j = 7; j >= 0; j--) {
            byte = (b[i] >> j) & 1;
            printf("%u", byte);
        }
    }
}

int assemble(char filePath[20], char outputPath[20], int manual, int debug) {
    FILE* assembly = fopen(filePath, "r");
    FILE* binary = fopen(outputPath, "w");

    if (!assembly)  {
        printf("Couldn't open: %s", filePath);
        return 1;
    } else if (!binary) {
        printf("Couldn't open: %s", outputPath);
        return 1;
    }

    int lineN = 0;

    char* line = NULL;
    size_t len = 0;
    ssize_t read = 0;

    printf("\n");

    while ((read = getline(&line, &len, assembly))) {
        char cmd[3][15] = {"", "", ""};
        int cmdc = 0;

        // parse parts of the file, save opcode/args to cmd
        // the number of args (+ opcode) is cmdc (thing program arguments)
        parseLine(&line, &cmdc, cmd);

        if (cmdc) {
            u_int32_t instruction = 0; // last 6 bits are unused
            int oneReg = 0; // is set to true if instruction only passes one register
            int opcode = getOpCode(cmd[0]); // the OP code of the instruction
            int rD = 0; // value of rD register (if any)
            int rA = 0; // value of rA register (if any)
            int val = 0; // constant passed with the instruction

            if (opcode == -1) {
                printf("Line %i: Couldn't parse opcode: %s", lineN, cmd[0]);
                return 1;
            }

            if (cmdc == 2) {
                if (opcode == PUSH || opcode == POP) {
                    rD = getRegCode(cmd[1]);

                    if (rD == UNDEFINED) {
                        printf("Line %i: Couldn't parse rD: %s", lineN, cmd[1]);
                        return 1;
                    }
                } else {
                    val = atoi(cmd[1]);
                }
            } else if (cmdc == 3) {
                // immediate stuff
                if (opcode == LDI || opcode == STI || opcode == ADDI ||
                    opcode == SUBI || opcode == ANDI ||
                    opcode == ORI || opcode == MULI || opcode == MULSI) {

                    oneReg = 1; // only one register is used

                    rD = getRegCode(cmd[1]);

                    if (rD == UNDEFINED) {
                        printf("Line %i: Couldn't parse rD: %s", lineN, cmd[1]);
                        return 1;
                    }

                    val = atoi(cmd[2]);
                } else {
                    rD = getRegCode(cmd[1]);

                    if (rD == UNDEFINED) {
                        printf("Line %i: Couldn't parse rD: %s", lineN, cmd[1]);
                        return 1;
                    }

                    rA = getRegCode(cmd[2]);

                    if (rA == UNDEFINED) {
                        printf("Line %i: Couldn't parse regcode: %s", lineN, cmd[2]);
                        return 1;
                    }
                }
            }

            if (debug) {
                printf("Line: %s", line);
            }

            /*
            ** The instruction is divided like this:
            **  opcode  rd    ra
            ** [......][...][....]
            **
            ** OR if constant is given instead of ra:
            **  opcode  rd         const
            ** [......][...][................]
             */

            u_int8_t registers = 0; // holds the registers byte
            registers |= rA;
            registers |= (rD << 4);

            instruction |= opcode;

            // if two registers given
            if (!oneReg) {
                instruction |= (registers << 8);
            // if value instead of ra
            } else {
                instruction |= (rD << 8);
                instruction |= (val << 16);
            }

            if (debug) {
                printf("opcode: ");
                printBits(1, &opcode);
                printf("\nregisters(Rd/Ra): ");
                printBits(1, &registers);
                printf("\nval: ");
                printBits(2, &val);
                printf("\n\n");
            }

            /*
            ** Since a file consists of bytes (also filesystems generally), every instruction line
            ** will have 6 unused bytes at the end of every line in the file.
            ** If file is inspected with:
            ** $ xxd -c 4 -b out.bin
            ** It should be evident.
             */

            if (manual) {
                printf("\"");
                printBits(4, &instruction);
                printf("\",\n");
            } else {
                fwrite(&instruction, 4, 1, binary);
            }
        }

        lineN++;

        if (read == -1)
            break;
    }

    return 0;
}

int getOpCode(char* text) {
    if (!strcmp(text, "NOP")) {
        return NOP;
    } else if (!strcmp(text, "RJMP")) {
        return RJMP;
    } else if (!strcmp(text, "BEQ")) {
        return BEQ;
    } else if (!strcmp(text, "BNE")) {
        return BNE;
    } else if (!strcmp(text, "BPL")) {
        return BPL;
    } else if (!strcmp(text, "BMI")) {
        return BMI;
    } else if (!strcmp(text, "BGE")) {
        return BGE;
    } else if (!strcmp(text, "BLT")) {
        return BLT;
    } else if (!strcmp(text, "LDI")) {
        return LDI;
    } else if (!strcmp(text, "LD")) {
        return LD;
    } else if (!strcmp(text, "STI")) {
        return STI;
    } else if (!strcmp(text, "ST")) {
        return ST;
    } else if (!strcmp(text, "COPY")) {
        return COPY;
    } else if (!strcmp(text, "ADD")) {
        return ADD;
    } else if (!strcmp(text, "ADDI")) {
        return ADDI;
    } else if (!strcmp(text, "SUB")) {
        return SUB;
    } else if (!strcmp(text, "SUBI")) {
        return SUBI;
    } else if (!strcmp(text, "CMP")) {
        return CMP;
    } else if (!strcmp(text, "AND")) {
        return AND;
    } else if (!strcmp(text, "ANDI")) {
        return ANDI;
    } else if (!strcmp(text, "OR")) {
        return OR;
    } else if (!strcmp(text, "ORI")) {
        return ORI;
    } else if (!strcmp(text, "PUSH")) {
        return PUSH;
    } else if (!strcmp(text, "POP")) {
        return POP;
    } else if (!strcmp(text, "ADC")) {
        return ADC;
    } else if (!strcmp(text, "SBC")) {
        return SBC;
    } else if (!strcmp(text, "MUL")) {
        return MUL;
    } else if (!strcmp(text, "MULI")) {
        return MULI;
    } else if (!strcmp(text, "MULS")) {
        return MULS;
    } else if (!strcmp(text, "MULSI")) {
        return MULSI;
    } else if (!strcmp(text, "LSLS")) {
        return LSLS;
    } else if (!strcmp(text, "LSLR")) {
        return LSLR;
    }

    return -1;
}

int getRegCode(char* text) {
    if (!strcmp(text, "A")) {
        return A;
    } else if (!strcmp(text, "B")) {
        return B;
    } else if (!strcmp(text, "C")) {
        return C;
    } else if (!strcmp(text, "D")) {
        return D;
    } else if (!strcmp(text, "E")) {
        return E;
    } else if (!strcmp(text, "F")) {
        return F;
    } else if (!strcmp(text, "G")) {
        return G;
    } else if (!strcmp(text, "H")) {
        return H;
    } else if (!strcmp(text, "I")) {
        return I;
    } else if (!strcmp(text, "J")) {
        return J;
    } else if (!strcmp(text, "K")) {
        return K;
    } else if (!strcmp(text, "L")) {
        return L;
    } else if (!strcmp(text, "M")) {
        return M;
    } else if (!strcmp(text, "N")) {
        return N;
    } else if (!strcmp(text, "O")) {
        return O;
    } else if (!strcmp(text, "P")) {
        return P;
    }

    return UNDEFINED;
}
void parseLine(char** line, int* cmdc, char cmd[3][15]) {
    *(cmdc) = 0;
    int cmdi = 0;
    int i = 0;

    while(1) {
        // remove whitespace/tabs from start of line
        while(line[0][i] == ' ' || line[0][i] == '\t') {
            i++;
        }

        // ignore rest since it's a comment
        if (line[0][i] == ';') {
            break;
        }

        // add string to cmd array
        while(line[0][i] != ' ' && line[0][i] != '\t' && line[0][i] != ',' && line[0][i] != '\n') {
            cmd[*cmdc][cmdi] = toupper(line[0][i]);
            cmdi++;
            i++;
        }

        if (cmdi)
            *(cmdc) += 1;

        // if EOL
        if (line[0][i] == '\n')
            break;

        cmdi = 0;
        i++;
    }
}

int main(int argc, char** argv) {
    if (argc <= 1) {
        printf("Syntax: ./asm -f ../assembly.asm -o ./build/output.bin");
        return 1;
    }

    int manual = 0;
    int debug = 0;
    char filePath[20] = "./input.asm";
    char outputPath[20] = "./out.bin";

    for(int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-i")) {
            strcpy(filePath, argv[i+1]);
            i++;
        } else if (!strcmp(argv[i], "-o")) {
            strcpy(outputPath, argv[i+1]);
            i++;
        } else if (!strcmp(argv[i], "-m")) {
            manual = 1;
        } else if (!strcmp(argv[i], "-d")) {
            debug = 1;
        }
    }

    return assemble(filePath, outputPath, manual, debug);
}
