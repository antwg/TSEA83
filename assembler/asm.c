#include "asm.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

/*
** TODO:
** - Negative numbers
** - Labels
** - Hex input for numbers
*/

/*
** Prints out the given amount of bytes ('size') from 'ptr'
** as if it was encoded with little-endian.
*/
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

/*
** Fetches a line from inputFile, sends it for parsing,
** and decode the instruction. Prints to stdout or writes
** to file depending on given flag in main.
*/
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

    char* line = NULL; // used to store every line read
    int lineN = 0; // current line number we're on
    size_t len = 0; // size of line read
    ssize_t read = 0; // amount read

    while ((read = getline(&line, &len, assembly))) {
        char cmd[3][15] = {"", "", ""}; // empty array to lose old contents
        int cmdc = 0;

        // Parse the line, save all parts of the instruction in cmd, and
        // keep the numebr of parts in cmdc.
        parseLine(&line, &cmdc, cmd);

        // If we actually read anything from the line.
        if (cmdc) {
            u_int32_t instruction = 0; // one full instruction
            u_int8_t opcode = getOpCode(cmd[0]); // the OP code of the instruction
            u_int8_t rD = 0; // value of rD register
            u_int8_t rA = 0; // value of rA register
            int val = 0; // the constant passed

            if (opcode == UNDEFINED) {
                printf("Line %i: Couldn't parse opcode: %s", lineN, cmd[0]);
                return 1;
            }

            // single argument instruction (e.x. PUSH 10)
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

            // double argument instruction (e.x. LD A,B)
            } else if (cmdc == 3) {

                // immediate stuff uses a constant
                if (opcode == LDI || opcode == STI || opcode == ADDI ||
                    opcode == SUBI || opcode == ANDI ||
                    opcode == ORI || opcode == MULI || opcode == MULSI) {

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

            // this is some ugly hax, yush!
            int val1 = (val >> 8) & 0xFF;
            int val2 = val & 0xFF;
            val = 0;
            val |= val1;
            val |= val2 << 8;

            if (debug) {
                u_int8_t registers = 0;
                registers |= rA;
                registers |= (rD << 4);

                printf("\n");
                printf("Line: %s", line);
                printf("Cmd0: %s, Cmd1: %s, Cmd2: %s\n", cmd[0], cmd[1], cmd[2]);
                printf("opcode: ");
                printBits(1, &opcode);
                printf("\nregisters(Rd/Ra): ");
                printBits(1, &registers);
                printf("\nval1: ");
                printBits(1, &val1);
                printf("\nval2: ");
                printBits(1, &val2);
                printf("\nval:  ");
                printBits(2, &val);
                printf("\n\n");
            }

            /*
            ** The instruction is divided like this:
            **  opcode  rD    rA      const
            ** [......][...][....][.............]
             */

            instruction |= opcode;
            instruction |= (rA << 8);
            instruction |= (rD << 12);
            instruction |= (val << 16);

            // Print it to stdout or write to file.
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

/*
** Parses one 'line' of assembly text. Takes its individual
** parts and saves it in a string array ('cmd'), the number of
** parts to the instruction is saved in 'cmdc'.
**
** E.g. for instruction: LDI A,B
** cmd[0] = "LDI"
** cmd[1] = A
** cmd[2] = B
** cmdc = 3
*/
void parseLine(char** lineP, int* cmdc, char cmd[3][15]) {
    char* line = lineP[0];
    *(cmdc) = 0; // number of parts in a instruction
    int c = 0; // current character of a part in the instruction
    int i = 0; // current character of line

    // continues to loop as long as a comment char nor newline is met
    while(1) {
        // Ignore whitespace/tabs from start of line
        while(line[i] == ' ' || line[i] == '\t') {
            i++;
        }

        // Ignore rest if it's a comment
        if (line[i] == ';')
            break;

        // add a part (continous sequence of non-whitespace and non ',' characters)
        // to parts array
        while(line[i] != ' ' && line[i] != '\t'
              && line[i] != ',' && line[i] != '\n') {
            cmd[*cmdc][c] = toupper(line[i]);
            c++;
            i++;
        }

        // if we've been adding characters, then
        // a part of the instruction was added to the cmd array
        if (c)
            *(cmdc) += 1;

        // If we've reached EOL we can stop parsing
        if (line[i] == '\n')
            break;

        // restart
        c = 0;
        i++;
    }
}

/*
** Flags:
** -i ./inputFile.asm [REQUIRED]
** -o ./outputFile.bin [DEFAULT=out.bin]
** -m [Prints instruction as binary for manual entering into program memory]
** -d [prints additional debug info]
*/
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

/*
** Returns the corresponding number for given instruction.
*/
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

    return UNDEFINED;
}

/*
** Returns the corresponding number for given register.
*/
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
