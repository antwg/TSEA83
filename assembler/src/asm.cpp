#include "asm.hpp"

#include <iostream>
#include <iomanip>
#include <sstream>

using std::string;
using std::vector;

void error(int lineNum, string line, string msg) {
    std::cout << "ERROR, line " << lineNum << ": " << msg << std::endl;
    std::cout << "> " << line << std::endl;
}

Assembler::Assembler() {
    setOutput(outputFilePath);
}

int Assembler::parseArgValue(string valueStr) {
    int value = 0;
    bool isHex = valueStr.find_first_of("$") != string::npos;
    bool isBin = valueStr.find_first_of("#") != string::npos;

    if (isHex) {
        value = stoi(valueStr.substr(1, string::npos), 0, 16);
    } else if (isBin) {
        value = stoi(valueStr.substr(1, string::npos), 0, 2);
    } else {
        value = stoi(valueStr);
    }

    return value;
}

int Assembler::checkInstruction(int opcode, vector<string> args) {
    // parse registers
    bool arg1IsLetters = args[1].find_first_not_of("ABCDEFGHIJKLMNOPQRSTUVWXYZ_") == string::npos;
    bool arg2IsLetters = args[2].find_first_not_of("ABCDEFGHIJKLMNOPQRSTUVWXYZ_") == string::npos;

    switch (opcode) {
        // We expect two registers
        case LD:
        case ST:
        case COPY:
        case ADD:
        case SUB:
        case CMP:
        case AND:
        case OR:
        case ADC:
        case SBC:
        case MUL:
        case MULS:
        case LSLS:
        case LSRS:
            if (!arg1IsLetters || !arg2IsLetters) {
                error(fileLineNum, fileLine, "Expects both arguments to be registers (letters)");
                return 1;
            }
            break;

        // We expect a register and a number
        case LDI:
        case STI:
        case ADDI:
        case SUBI:
        case CMPI:
        case ANDI:
        case ORI:
            if (!arg1IsLetters || arg2IsLetters) {
                error(fileLineNum, fileLine, "Expects a letter and a number as arguments");
                return 1;
            }
            break;

        // We expect one argument, as label or number
        case RJMP:
        case BEQ:
        case BNE:
        case BPL:
        case BMI:
        case BGE:
        case BLT:
            if (args[1] == "") {
                error(fileLineNum, fileLine, "Expecting an argument for instruction");
                return 1;
            }
            break;

        // We expect a register
        case PUSH:
        case POP:
            if (!arg1IsLetters) {
                error(fileLineNum, fileLine, "Expecting a register.");
                return 1;
            }
            break;
    }

    return 0;
}

int Assembler::setInput(string path) {
    inputFile.open(path);

    if(!inputFile.is_open()) {
        std::cout << "Couldn't open file: " << path << std::endl;
        return 1;
    }

    return 0;
}

int Assembler::setOutput(string path) {
    outputFile.open(path);

    if(!outputFile.is_open()) {
        std::cout << "Couldn't open file: " << path << std::endl;
        return 1;
    }

    return 0;
}

int Assembler::run() {
    if (parseLines())
	    return 1;

    if (updateLabels())
        return 1;

    if (write())
        return 1;

    return 0;
}

int Assembler::parseLines() {
    for(string line; std::getline(inputFile, line);) {
        this->fileLineNum++;
        this->fileLine = line;

        long unsigned n = line.find_first_not_of(" \t\n\v\f\r");

        // line isn't empty nor a comment
        if (n != string::npos && line.at(n) != ';') {

            // Initialize the instruction to store
            Instruction instr;
            instr.opcode = UNDEFINED;
            instr.registers = 0;
            instr.value = 0;
            instr.labelName = "";
            instr.fileLineNum = fileLineNum;
            instr.pmLineNum = instructions.size();
            instr.fileLine = line;

            bool lineIsLabel = line.find_first_of(":") != string::npos;

            if (lineIsLabel) {
                // extract the label name
                string label = line.substr(n, line.find(":"));

                // store where the label is in program memory
                labels[label] = instructions.size();

                instr.opcode = LBL;
                instr.labelName = label;

                if (debug) {
                    std::cout << "------LBL------" << std::endl;
                    std::cout << "Line: " << instr.fileLine << std::endl;
                    std::cout << "Label: " << instr.labelName << std::endl;
                    std::cout << "At line: " << instr.pmLineNum << std::endl;
                }

                // skip to next line
                continue;

            // it is an instruction
            } else {
                if (debug) {
                    std::cout << "------INSTR-----" << std::endl;
                    std::cout << "Line: " << line << std::endl;
                }

                // remove starting whitespace and fetch instruction arguments
                vector<string> arg = getInstrArgs(line.substr(n, line.size()));

                if (debug) {
                    std::cout << "Arg0: " << arg[0] << std::endl;
                    std::cout << "Arg1: " << arg[1] << std::endl;
                    std::cout << "Arg2: " << arg[2] << std::endl;
                }

                instr.opcode = getOpCode(arg[0]);
                if (instr.opcode == UNDEFINED) {
                    error(fileLineNum, line, "Couldn't parse opcode: " + arg[0]);
                    return 1;
                }

                // We do some failchecking to spare headaches for the programmer.
                if(checkInstruction(instr.opcode, arg))
                    return 1;

                // so that we know what type the argument is
                bool arg1IsLetters = arg[1].find_first_not_of("ABCDEFGHIJKLMNOPQRSTUVWXYZ_") == string::npos;
                bool arg2IsLetters = arg[2].find_first_not_of("ABCDEFGHIJKLMNOPQRSTUVWXYZ_") == string::npos;

                // temporary storage
                int registers = 0;
                int arg1Reg = 0;
                int arg2Reg = 0;
                int value = 0;
                string labelName = "";

                bool jumpInstr = instr.opcode == RJMP || instr.opcode == BEQ ||
                                 instr.opcode == BNE  || instr.opcode == BPL ||
                                 instr.opcode == BMI  || instr.opcode == BGE ||
                                 instr.opcode == BLT  || instr.opcode == SUBR;

                // Parse the arguments differently depending on what instruction is given
                // If it's a jump, the argument can be a number or a label
                if (jumpInstr) {
                    // if arg1 is a label
                    if(arg1IsLetters) {
                        labelName = arg[1];

                        // add this line to be handled later, once we've read all labels
                        labelsInstructions.push_back(instr.pmLineNum);

                    // else we've the actual offset as a number
                    } else {
                        value = parseArgValue(arg[1]);
                    }

                // if not a jump instruction, arguments are either numbers or registers
                } else {
                    // arg1 is register
                    if (arg[1].size() && arg1IsLetters) {
                        arg1Reg = getRegCode(arg[1]);

                        if (arg1Reg == UNDEFINED) {
                            error(fileLineNum, line, "Couldn't parse register value: " + arg[1]);
                            return 1;
                        }

                    // arg1 is number
                    } else if (arg[1].size()) {
                        value = parseArgValue(arg[1]);
                    }

                    // arg2 is register
                    if (arg[2].size() && arg2IsLetters) {
                        arg2Reg = getRegCode(arg[2]);

                        if (arg2Reg == UNDEFINED) {
                            error(fileLineNum, line, "Couldn't parse register value: " + arg[2]);
                            return 1;
                        }

                    // arg2 is number
                    } else if (arg[2].size()) {
                        value = parseArgValue(arg[2]);
                    }
                }

                registers += arg1Reg << 4;
                registers += arg2Reg;

                // set the values fetched to the instruction
                instr.value = value;
                instr.registers = registers;
                instr.labelName = labelName;

                if (debug) {
                    std::cout << "--" << std::endl;
                    printf("OP: %.2X\n", instr.opcode);
                    printf("Regs: %.2X\n", instr.registers);
                    printf("Value: %.4X\n", instr.value);
                }

                instructions.push_back(instr);
            }
        }
    }

    return 0;
}

vector<string> Assembler::getInstrArgs(string line) {
    vector<string> instr = {"", "", ""}; // TODO: make to string[3]
    bool EOL = false;
    int part = 0;
    int i = 0;

    // extract args from line
    while(true) {
        // Ignore whitespace/tabs from start of line
        while(line.at(i) == ' ' || line.at(i) == '\t') {
            i++;

            // EOL
            if (i >= (int)line.size()) {
                EOL = true;
                break;
            }
        }

        // add a part (continous sequence of wanted characters)
        while (!EOL && line.at(i) != ' ' && line.at(i) != '\t' &&
                line.at(i) != ',' && line.at(i) != '\n' &&
                line.at(i) != ';') {
            instr[part].push_back(toupper(line[i]));

            i++;

            // EOL
            if (i >= (int)line.size()) {
                EOL = true;
                break;
            }
        }

        // if we've been adding characters, then
        // a part of the instruction was added to the cmd array
        if (instr[part].size()) {
            instr.push_back("");
            part++;
        }

        // Quit if EOL reached
        if (EOL)
            break;

        // Ignore rest if it's a comment, or we've reached EOL
        if (line.at(i) == ';' || line.at(i) == '\n')
            break;

        i++;

        // EOL
        if (i >= (int)line.size())
            break;
    }

    return instr;
}

int Assembler::updateLabels() {
    if (debug && labelsInstructions.size()) {
        std::cout << "--------LABELS------" << std::endl;
    }

    for (int line : labelsInstructions) {
        Instruction instr = instructions[line];

        if ((int)instr.pmLineNum <= (int)labels[instr.labelName]) {
            instr.value = labels[instr.labelName] - instr.pmLineNum;
        } else {
            instr.value = labels[instr.labelName] - instr.pmLineNum;
        }

        instructions[line] = instr;

        if (debug) {
            std::cout << "----" << std::endl;
            std::cout << "Line: " << instr.fileLine << std::endl;
            std::cout << "Label: " << instr.labelName << std::endl;
            std::cout << "Instr. at: " << instr.pmLineNum << std::endl;
            std::cout << "Label at: " << labels[instr.labelName] << std::endl;
            std::cout << "Jump: " << instr.value << std::endl;
        }
    }

    return 0;
}

int Assembler::write() {
    for(Instruction instr : instructions) {
        if (manual) {
            if (instr.opcode != LBL) {
                printf("x\"");
                printf("%.2X", instr.opcode);
                printf("%.2X", instr.registers);
                printf("%.4X", (instr.value & 0xFFFF));
                printf("\", -- ");
                std::cout << instr.fileLine << std::endl;
            }
        }

        char val1 = instr.value & 0x00FF;
        char val2 = (instr.value & 0xFF00) >> 8;

        outputFile.write((char*)&instr.opcode, sizeof(char));
        outputFile.write((char*)&instr.registers, sizeof(char));
        outputFile.write(&val1, sizeof(char));
        outputFile.write(&val2, sizeof(char));
    }

    char eof = 0xFF;
    outputFile.write(&eof, sizeof(char));
    outputFile.close();

    return 0;
}

int Assembler::getRegCode(string txt) {
    if (!txt.compare("A")) {
        return A;
    } else if (!txt.compare("B")) {
        return B;
    } else if (!txt.compare("C")) {
        return C;
    } else if (!txt.compare("D")) {
        return D;
    } else if (!txt.compare("E")) {
        return E;
    } else if (!txt.compare("F")) {
        return F;
    } else if (!txt.compare("G")) {
        return G;
    } else if (!txt.compare("H")) {
        return H;
    } else if (!txt.compare("I")) {
        return I;
    } else if (!txt.compare("J")) {
        return J;
    } else if (!txt.compare("K")) {
        return K;
    } else if (!txt.compare("L")) {
        return L;
    } else if (!txt.compare("M")) {
        return M;
    } else if (!txt.compare("N")) {
        return N;
    } else if (!txt.compare("O")) {
        return O;
    } else if (!txt.compare("P")) {
        return P;
    }

    return UNDEFINED;
}

int Assembler::getOpCode(string txt) {
    if (!txt.compare("NOP")) {
        return NOP;
    } else if (!txt.compare("RJMP")) {
        return RJMP;
    } else if (!txt.compare("BEQ")) {
        return BEQ;
    } else if (!txt.compare("BNE")) {
        return BNE;
    } else if (!txt.compare("BPL")) {
        return BPL;
    } else if (!txt.compare("BMI")) {
        return BMI;
    } else if (!txt.compare("BGE")) {
        return BGE;
    } else if (!txt.compare("BLT")) {
        return BLT;
    } else if (!txt.compare("LDI")) {
        return LDI;
    } else if (!txt.compare("LD")) {
        return LD;
    } else if (!txt.compare("STI")) {
        return STI;
    } else if (!txt.compare("ST")) {
        return ST;
    } else if (!txt.compare("COPY")) {
        return COPY;
    } else if (!txt.compare("ADD")) {
        return ADD;
    } else if (!txt.compare("ADDI")) {
        return ADDI;
    } else if (!txt.compare("SUB")) {
        return SUB;
    } else if (!txt.compare("SUBI")) {
        return SUBI;
    } else if (!txt.compare("CMP")) {
        return CMP;
    } else if (!txt.compare("CMPI")) {
        return CMPI;
    } else if (!txt.compare("AND")) {
        return AND;
    } else if (!txt.compare("ANDI")) {
        return ANDI;
    } else if (!txt.compare("OR")) {
        return OR;
    } else if (!txt.compare("ORI")) {
        return ORI;
    } else if (!txt.compare("PUSH")) {
        return PUSH;
    } else if (!txt.compare("POP")) {
        return POP;
    } else if (!txt.compare("ADC")) {
        return ADC;
    } else if (!txt.compare("SBC")) {
        return SBC;
    } else if (!txt.compare("MUL")) {
        return MUL;
    } else if (!txt.compare("MULI")) {
        return MULI;
    } else if (!txt.compare("MULS")) {
        return MULS;
    } else if (!txt.compare("MULSI")) {
        return MULSI;
    } else if (!txt.compare("LSLS")) {
        return LSLS;
    } else if (!txt.compare("LSRS")) {
        return LSRS;
    } else if (!txt.compare("PUSR")) {
	    return PUSR;
    } else if (!txt.compare("POSR")) {
	    return POSR;
    } else if (!txt.compare("SUBR")) {
	    return SUBR;
    } else if (!txt.compare("RET")) {
	    return RET;
    } else if (!txt.compare("RTI")) {
	    return RTI;
    }

    return UNDEFINED;
}
