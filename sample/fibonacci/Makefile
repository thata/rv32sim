all: fibonacci.rom

clean:
	rm -f *.o *.elf *.rom

startup.o:
	riscv64-unknown-elf-gcc -O0 -march=rv32i -mabi=ilp32 -c startup.S

main.o:
	riscv64-unknown-elf-gcc -O0 -march=rv32i -mabi=ilp32 -c main.c

fibonacci.elf: startup.o main.o
	riscv64-unknown-elf-ld -m elf32lriscv -b elf32-littleriscv -Trv32sim.ld startup.o main.o -o fibonacci.elf

fibonacci.rom: fibonacci.elf
	riscv64-unknown-elf-objcopy -O binary fibonacci.elf fibonacci.rom

run:
	ruby ../../rv32sim.rb fibonacci.rom

dump:
	riscv64-unknown-elf-objdump -S fibonacci.elf
