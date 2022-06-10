# 4649
#
# $ riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wl,-Ttext=0x00 -nostdlib -o 4649 4649.S
# $ riscv64-unknown-elf-objcopy -O binary 4649 4649.rom
# $ ruby rv32sim.rb 4649.rom

  .text
  .globl _start
  .type _start, @function
_start:
  addi x1, x0, 0x46 # x1 = ヨロ(46)
  addi x2, x0, 0x49 # x2 = シク(49)
  nop
  nop
  nop
  nop
  nop
