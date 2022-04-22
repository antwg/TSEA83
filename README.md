# PipeCPU

En tvåstegad pipeline CPU för TSEA83 kursen.

## Simulera

[Få åtkomst till modelsim](https://www.isy.liu.se/edu/kurs/TSEA83/distansarbete/).

Kör sedan simulationen med kommandot `make pipecpu.sim` i **./src/** mappen. Kör om simulationen genom att köra `do pipecpu.do` i transcript fönstret i modelsim.

## Ladda upp program
Se till att du make:at i ./assembler/ mappen så att ./assembler/asm programmet finns.

Kör sedan `./asm -i assemblyFil.asm`. Den kommer skapa en fil som heter out.bin i samma mapp som programmet ligger i. Ladda upp den till kortet genom att köra `cat out.bin > /dev/ttyUSB0` (just adressen /dev/ttyUSB0 kan ändra sig, så finns den inte så ligger den nog på USB1 eller dyl...).
