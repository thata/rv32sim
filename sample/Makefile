roms = 4649.rom fibonacci.rom hello.rom loopback.rom

all: $(roms)

%.rom: %.elf
	riscv64-unknown-elf-objcopy -O binary $< $@

%.elf: %.S
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wl,-Ttext=0x00 -nostdlib -o $@ $<

clean:
	rm -rf *.elf *.rom
