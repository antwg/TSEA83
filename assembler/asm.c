#include "asm.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#include <sys/types.h>

/*
** TODO:
** - Check so that we don't allow compiling programs that has more lines than memory has space
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

    for (i = size - 1; i >= 0; i--) {
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
int assemble(char filePath[40], char outputPath[40], int manual, int debug) {
    FILE* assembly = fopen(filePath, "r");
    FILE* binaryOutput = fopen(outputPath, "w");

    if (!assembly)  {
        printf("Couldn't open: %s\n", filePath);
        return 1;
    } else if (!binaryOutput) {
        printf("Couldn't open: %s\n", outputPath);

        if (!manual)
            return 1;
    }

    char* line = NULL; // used to store every line read
    int lineN = 1; // current line number we're on
    size_t len = 0; // size of line read
    ssize_t read = 0; // amount read

    while ((read = getline(&line, &len, assembly))) {
        // If we read nothing, EOF
        if (read == -1) {
            // write EOF indicator to file (so bootloader knows where to stop reading)
            if (binaryOutput) {
                u_int32_t eof = 0xFF;
                fwrite(&eof, 1, 1, binaryOutput);
            }

            break;
        }

        char cmd[3][40] = {"", "", ""}; // empty array to lose old contents
        int cmdc = 0;

        // Parse the line, save all parts of the instruction in cmd, and
        // keep the numebr of parts in cmdc.
        parseLine(&line, &cmdc, cmd);

        // If we actually read anything from the line.
        if (cmdc) {
            u_int8_t opcode = getOpCode(cmd[0]); // the OP code of the instruction
            u_int8_t rD = 0; // value of rD register
            u_int8_t rA = 0; // value of rA register
            int val = 0; // the constant passed

            if (opcode == UNDEFINED) {
                printf("Line %i: Couldn't parse opcode: %s\n", lineN, cmd[0]);
                return 1;
            }

            // single argument instruction (e.x. PUSH 10)
            if (cmdc == 2) {
                if (opcode == PUSH || opcode == POP || opcode == LSLS || opcode == LSRS) {
                    rD = getRegCode(cmd[1]);

                    if (rD == UNDEFINED) {
                        printf("Line %i: Couldn't parse rD: %s\n", lineN, cmd[1]);
                        return 1;
                    }
                } else {
                    val = atoi(cmd[1]);
                }

            // double argument instruction (e.x. LD A,B)
            } else if (cmdc == 3) {

                // immediate stuff uses a constant
                if (opcode == LDI || opcode == STI || opcode == ADDI ||
                    opcode == SUBI || opcode == ANDI || opcode == CMPI ||
                    opcode == ORI || opcode == MULI || opcode == MULSI) {

                    rD = getRegCode(cmd[1]);

                    if (rD == UNDEFINED) {
                        printf("Line %i: Couldn't parse rD: %s\n", lineN, cmd[1]);
                        return 1;
                    }

                    val = atoi(cmd[2]);
                } else {
                    rD = getRegCode(cmd[1]);

                    if (rD == UNDEFINED) {
                        printf("Line %i: Couldn't parse rD: %s\n", lineN, cmd[1]);
                        return 1;
                    }

                    rA = getRegCode(cmd[2]);

                    if (rA == UNDEFINED) {
                        printf("Line %i: Couldn't parse regcode: %s\n", lineN, cmd[2]);
                        return 1;
                    }
                }
            }

            u_int8_t registers = 0;
            registers |= rA;
            registers |= (rD << 4);

            if (debug) {
                printf("\n\n");
                printf("-------------------------\n");
                printf("Line: %s", line);
                printf("Args: %d\n", cmdc);
                printf("Arg0: %s, Arg1: %s, Arg2: %s\n", cmd[0], cmd[1], cmd[2]);
                printf("opcode: ");
                printBits(1, &opcode);
                printf(" (%.2X)", opcode);
                printf("\nregisters(Rd/Ra): ");
                printBits(1, &registers);
                printf(" (%.2X)", registers);
                printf("\nval:  ");
                printBits(2, &val);
                printf(" (%.4X)", (val & 0xFFFF));
                printf("\n\n");
            }

            /*
            ** The instruction is divided like this:
            **  opcode  rD    rA      const
            ** [......][...][....][.............]
             */

            // Print it to stdout or write to file.
            if (manual) {
                printf("x\"");
                //printBits(1, &opcode);
                //printBits(1, &registers);
                //printBits(2, &val);
                printf("%.2X", opcode);
                printf("%.2X", registers);
                printf("%.4X", (val & 0xFFFF));
                printf("\", -- %s", line);
            }

            if (binaryOutput) {
                fwrite(&opcode, 1, 1, binaryOutput);
                fwrite(&registers, 1, 1, binaryOutput);
                fwrite(&val, 2, 1, binaryOutput);
            }
        }

        lineN++;
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
void parseLine(char** lineP, int* cmdc, char cmd[3][40]) {
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

        // add a part (continous sequence of characters, ignore whitespace, {',', ';'})
        // to parts array
        while(line[i] != ' ' && line[i] != '\t'
              && line[i] != ',' && line[i] != '\n'
              && line[i] != ';') {
            cmd[*cmdc][c] = toupper(line[i]);
            c++;
            i++;
        }

        // if we've been adding characters, then
        // a part of the instruction was added to the cmd array
        if (c)
            *(cmdc) += 1;

        // Ignore rest if it's a comment, or we've reached EOL
        if (line[i] == ';' || line[i] == '\n')
            break;

        // restart
        c = 0;
        i++;
    }
}

/*
** Flags:
** -i ./inputFile.asm [REQUIRED]
** -o ./outputFile.bin
** -m [Prints instruction as binary for manual entering into program memory]
** -d [prints additional debug info]
*/
int main(int argc, char** argv) {
    if (argc <= 1) {
        printHelp();
        return 1;
    }

    int manual = 0;
    int debug = 0;
    char filePath[40] = "./example.asm";
    char outputPath[40] = "./out.bin";

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
        } else if (!strcmp(argv[i], "-h")) {
            printHelp();
            return 0;
        }
    }

    return assemble(filePath, outputPath, manual, debug);
}


/*
** Prints help information.
**/
void printHelp() {
    printf("Syntax: ./asm -i ../assembly.asm -o ./build/output.bin -m -d\n");
    printf("-i inputFile (default=./example.asm)\n");
    printf("-o outputFile (default=./out.bin)\n");
    printf("-m print instructions formatted to terminal\n");
    printf("-d print debug information\n");
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
    } else if (!strcmp(text, "CMPI")) {
        return CMPI;
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
    } else if (!strcmp(text, "LSRS")) {
        return LSRS;
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
