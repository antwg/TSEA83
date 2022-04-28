#include "asm.hpp"

#include <iostream>
#include <iomanip>
#include <sstream>

void error(int lineNum, std::string line, std::string msg) {
    std::cout << "ERROR, line " << lineNum << ": " << msg << std::endl;
    std::cout << "> " << line << std::endl;
}

Assembler::Assembler() {
    setOutput(outputFilePath);
}

int toHex(std::string hex) {
    unsigned int x;
    std::stringstream ss;
    ss << std::hex << hex;
    ss >> x;

    return x;
}

int Assembler::setInput(std::string path) {
    inputFile.open(path);

    if(!inputFile.is_open()) {
        std::cout << "Couldn't open file: " << path << std::endl;
        return 1;
    }

    return 0;
}

int Assembler::setOutput(std::string path) {
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
    int currentLine = 1;

    // First extract all relevant data and check that
    // it is reasonable input (e.g. opcodes are OK et.c.)
    for(std::string line; std::getline(inputFile, line);) {
        long unsigned n = line.find_first_not_of(" \t\n\v\f\r");

        // line isn't empty nor a comment
        if (n != std::string::npos && line.at(n) != ';') {

            // Initialize the instruction to store
            Instruction instr;
            instr.opcode = UNDEFINED;
            instr.registers = 0;
            instr.value = 0;
            instr.labelName = "";
            instr.fileLine = currentLine;
            instr.pmLine = instructions.size();
            instr.line = line;

            // Current line is a label
            if (line.find_first_of(":") != std::string::npos) {
                // extract the label name
                std::string label = line.substr(n, line.find(":"));
                labels[label] = instructions.size(); // add where label is in program memory

                instr.opcode = LBL;
                instr.labelName = label;

                if (debug) {
                    std::cout << "------LBL------" << std::endl;
                    std::cout << "Line: " << instr.line << std::endl;
                    std::cout << "Label: " << instr.labelName << std::endl;
                    std::cout << "At line: " << instr.pmLine << std::endl;
                }

                currentLine++;
                continue;

            // it is a instruction
            } else {
                if (debug) {
                    std::cout << "------INSTR-----" << std::endl;
                    std::cout << "Line: " << line << std::endl;
                }

                std::vector<std::string> arg = extractInstructionArgs(line.substr(n, line.size()));

                if (debug) {
                    std::cout << "Arg0: " << arg[0] << std::endl;
                    std::cout << "Arg1: " << arg[1] << std::endl;
                    std::cout << "Arg2: " << arg[2] << std::endl;
                }

                int op = getOpCode(arg[0]);
                if (op == UNDEFINED) {
                    error(currentLine, line, "Couldn't parse opcode: " + arg[0]);
                    return 1;
                }

                instr.opcode = op;

                // parse registers
                bool arg1IsLetters = arg[1].find_first_not_of("ABCDEFGHIJKLMNOPQRSTUVWXYZ_") == std::string::npos;
                bool arg2IsLetters = arg[2].find_first_not_of("ABCDEFGHIJKLMNOPQRSTUVWXYZ_") == std::string::npos;

                bool isHexArg1 = arg[1].find_first_of("$") != std::string::npos;
                bool isHexArg2 = arg[2].find_first_of("$") != std::string::npos;

                // We do some failchecking to spare headaches for programmer
                // check so thet we get registers when doing specific instructions
                if (instr.opcode == COPY || instr.opcode == ADD  || instr.opcode == SUB  ||
                    instr.opcode == CMP  || instr.opcode == AND  || instr.opcode == OR   ||
                    instr.opcode == ADC  || instr.opcode == SBC  || instr.opcode == MUL  ||
                    instr.opcode == MULS || instr.opcode == LSLS || instr.opcode == LSRS ||
                    instr.opcode == LSRS ) {
                    if (!arg1IsLetters || !arg2IsLetters) {
                        error(currentLine, line, "Expects both arguments to be registers (letters)");
                        return 1;
                            
                    }

                }

                // Parse the arguments differently depending on what type of instruction it is
                // If it's a jump, the argument can be a number or a label
                if (instr.opcode == RJMP || instr.opcode == BEQ || instr.opcode == BNE ||
                    instr.opcode == BPL || instr.opcode == BMI || instr.opcode == BGE ||
                    instr.opcode == BLT || instr.opcode == SUBR) {

                    // if arg1 is a label
                    if(arg1IsLetters) {
                        instr.labelName = arg[1];

                        // add this line to be handled later, once we've read all labels
                        labelsInstructions.push_back(instr.pmLine);

                    // else we've the actual offset as a number
                    } else {
                        if (isHexArg1) {
                            instr.value = toHex(arg[1].substr(1, std::string::npos));
                        } else {
                            instr.value = stoi(arg[1]);
                        }
                    }

                // if not a jump instruction, arguments are either numbers or registers
                } else {
                    int registers = 0;
                    int arg1Reg = 0;
                    int arg2Reg = 0;
                    int value = 0;

                    // arg1 is register
                    if (arg[1].size() && arg1IsLetters) {
                        arg1Reg = getRegCode(arg[1]);

                        if (arg2Reg == UNDEFINED) {
                            std::cout << "Couldn't parse register: \'" << arg[1] << "\'" << std::endl;
                            return 1;
                        }

                    // arg1 is number
                    } else if (arg[1].size()) {
                        if (isHexArg1) {
                            value = toHex(arg[1].substr(1, std::string::npos));
                        } else {
                            value = stoi(arg[1]);
                        }
                    }

                    // arg2 is register
                    if (arg[2].size() && arg2IsLetters) {
                        arg2Reg = getRegCode(arg[2]);

                        if (arg2Reg == UNDEFINED) {
                            std::cout << "Couldn't parse register: \'" << arg[2] << "\'" << std::endl;
                            return 1;
                        }

                    // arg2 is number
                    } else if (arg[2].size()) {
                        if (isHexArg2) {
                            value = toHex(arg[2].substr(1, std::string::npos));
                        } else {
                            value = stoi(arg[2]);
                        }
                    }

                    registers += arg1Reg << 4;
                    registers += arg2Reg;

                    instr.value = value;
                    instr.registers = registers;
                }

                if (debug) {
                    std::cout << "--" << std::endl;
                    printf("OP: %.2X\n", instr.opcode);
                    printf("Regs: %.2X\n", instr.registers);
                    printf("Value: %.4X\n", instr.value);
                }

                instructions.push_back(instr);

                currentLine++;
            }
        }
    }

    return 0;
}

std::vector<std::string> Assembler::extractInstructionArgs(std::string line) {
    std::vector<std::string> instr = {"", "", ""}; // TODO: make to string[3]
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

        if ((int)instr.pmLine <= (int)labels[instr.labelName]) {
            instr.value = labels[instr.labelName] - instr.pmLine;
        } else {
            instr.value = labels[instr.labelName] - instr.pmLine;
        }

        instructions[line] = instr;

        if (debug) {
            std::cout << "----" << std::endl;
            std::cout << "Line: " << instr.line << std::endl;
            std::cout << "Label: " << instr.labelName << std::endl;
            std::cout << "Instr. at: " << instr.pmLine << std::endl;
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
                std::cout << instr.line << std::endl;
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

int Assembler::getRegCode(std::string txt) {
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

int Assembler::getOpCode(std::string txt) {
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
