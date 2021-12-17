# 4649
#
# $ riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wl,-Ttext=0x00 -nostdlib -o sample sample.s
# $ riscv64-unknown-elf-objcopy -O binary sample sample.rom
# $ ruby rv32sim.rb sample.rom

  .text
  .globl _start
  .type _start, @function
_start:
  addi x1, x0, 0x46
  addi x2, x0, 0x49
  sw x1, 0(x0)
  sw x2, 16(x0)
  nop
  nop
  nop
  nop
  nop
