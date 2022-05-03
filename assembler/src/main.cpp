#include "asm.cpp"
#include <cstring>

/*
** Prints help information.
**/
void printHelp() {
    printf("Syntax: ./asm -i ../assembly.asm -o ./build/output.bin -m -d\n");
    printf("-i inputFile (default=./example.asm)\n");
    printf("-o outputFile (default=./out.bin)\n");
    printf("-t if not used, adds a NOP to the interrupt vector\n");
    printf("-m print instructions formatted to terminal\n");
    printf("-d print debug information\n");
    printf("-u automatically upload resulting file to uart\n");
}

/*
** -u [uploads to UART, doesn't configure UART]
*/
int main(int argc, char** argv) {
    if (argc <= 1) {
        printHelp();
        return 1;
    }

    Assembler engine;

    for(int i = 1; i < argc; i++) {
        if (!strcmp(argv[i], "-i")) {
            if (engine.setInput(argv[i+1]))
                return 0;
            i++; // skip filepath arg
        } else if (!strcmp(argv[i], "-o")) {
            if (engine.setOutput(argv[i+1]))
                return 0;
            i++; // skip filepath arg
        } else if (!strcmp(argv[i], "-m")) {
            engine.config[manual] = true;
        } else if (!strcmp(argv[i], "-d")) {
            engine.config[debug] = true;
        } else if (!strcmp(argv[i], "-h")) {
            printHelp();
            return 0;
        } else if (!strcmp(argv[i], "-t")) {
            engine.config[interrupts] = true;
        } else if (!strcmp(argv[i], "-u")) {
            engine.config[uart] = true;
        }
    }

    return engine.run();
}
