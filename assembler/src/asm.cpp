#include "asm.hpp"

#include <iostream>
#include <iomanip>
#include <sstream>

using std::string;
using std::vector;
using std::cout;
using std::endl;

Assembler::Assembler() {
    // Default file paths
    setOutput(outputFilePath);
}

int Assembler::setInput(string path) {
    inputFile.open(path);

    if(!inputFile.is_open()) {
        cout << "Couldn't open file: " << path << endl;
        return 1;
    }

    return 0;
}

int Assembler::setOutput(string path) {
    outputFile.open(path);

    if(!outputFile.is_open()) {
        cout << "Couldn't open file: " << path << endl;
        return 1;
    }

    return 0;
}

int Assembler::run() {
    if (!inputFile.is_open()) {
        cout << "No input file given..." << endl;
        return 1;
    }

    if (parseLines())
        return 1;

    if (updateLabels())
        return 1;

    if (write())
        return 1;

    return 0;
}

int Assembler::parseLines() {
    // add a NOP to the interrupt vector for the user
    if (!config["interrupts"]) {
        Instruction nop = {NOP, 0, 0, "", 0, 0, "interrupt vector"};
        instructions.push_back(nop);
    }

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

                if (config["debug"]) {
                    cout << "------LBL------" << endl;
                    cout << "Line: " << instr.fileLine << endl;
                    cout << "Label: " << instr.labelName << endl;
                    cout << "At line: " << instr.pmLineNum << endl;
                }

                // skip to next line
                continue;

            // it is an instruction
            } else {
                if (config["debug"]) {
                    cout << "------INSTR-----" << endl;
                    cout << "Line: " << line << endl;
                }

                // remove starting whitespace and fetch instruction arguments
                vector<string> arg = getInstrArgs(line.substr(n, line.size()));

                if (config["debug"]) {
                    cout << "Arg0: " << arg[0] << endl;
                    cout << "Arg1: " << arg[1] << endl;
                    cout << "Arg2: " << arg[2] << endl;
                }

                instr.opcode = getOpCode(arg[0]);
                if (instr.opcode == UNDEFINED) {
                    logError("Couldn't parse opcode: " + arg[0]);
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
                            logError("Couldn't parse register value: " + arg[1]);
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
                            logError("Couldn't parse register value: " + arg[2]);
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

                if (config["debug"]) {
                    cout << "--" << endl;
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

int Assembler::updateLabels() {
    if (config["debug"] && labelsInstructions.size()) {
        cout << "--------LABELS------" << endl;
    }

    for (int line : labelsInstructions) {
        Instruction instr = instructions[line];
        instr.value = labels[instr.labelName] - instr.pmLineNum;

        instructions[line] = instr;

        if (config["debug"]) {
            cout << "----" << endl;
            cout << "Line: " << instr.fileLine << endl;
            cout << "Label: " << instr.labelName << endl;
            cout << "Instr. at: " << instr.pmLineNum << endl;
            cout << "Label at: " << labels[instr.labelName] << endl;
            cout << "Jump: " << instr.value << endl;
        }
    }

    return 0;
}

int Assembler::write() {
    for(Instruction instr : instructions) {
        if (config["manual"]) {
            if (instr.opcode != LBL) {
                printf("x\"");
                printf("%.2X", instr.opcode);
                printf("%.2X", instr.registers);
                printf("%.4X", (instr.value & 0xFFFF));
                printf("\", -- ");
                cout << instr.fileLine << endl;
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

    // write to uart device (should've been configured by user)
    if (config["uart"]) {
        std::ifstream outFile;
        outFile.open(outputFilePath, std::ifstream::binary);

        std::filebuf* outBuf = outFile.rdbuf();

        // get file size
        std::size_t size = outBuf->pubseekoff(0, outFile.end, outFile.in);

        // allocate mem to keep file data
        char* buffer = new char[size];

        // get file data
        outBuf->sgetn(buffer, size);

        outFile.close();

        std::ofstream uartDev;
        uartDev.open("/dev/ttyUSB0");

        if (!uartDev.is_open()) {
            cout << "Couldn't open /dev/ttyUSB0 for writing" << endl;
            return 1;
        }

        uartDev.write(buffer, size);
        uartDev.close();
    }

    return 0;
}


/* -----------------
 *  HELPER FUNCTIONS
 * -----------------
 */

void Assembler::logError(string msg) {
    cout << "ERROR, line " << fileLineNum << ": " << msg << endl;
    cout << "> " << fileLine << endl;
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
                logError("Expects both arguments to be registers (letters)");
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
                logError("Expects a letter and a number as arguments");
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
                logError("Expecting an argument for instruction");
                return 1;
            }
            break;

        // We expect a register
        case PUSH:
        case POP:
            if (!arg1IsLetters) {
                logError("Expecting a register.");
                return 1;
            }
            break;
    }

    return 0;
}


int Assembler::getRegCode(string txt) {
    if (regCodes.count(txt))
        return regCodes[txt];

    return UNDEFINED;
}

int Assembler::getOpCode(string txt) {
    if (opCodes.count(txt))
        return opCodes[txt];

    return UNDEFINED;
}
