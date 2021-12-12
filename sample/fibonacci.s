# fibonacci for RV32
#
# $ riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wl,-Ttext=0x00 -nostdlib -o fibonacci fibonacci.s
# $ riscv64-unknown-elf-objcopy -O binary fibonacci fibonacci.rom
# $ ruby rv32sim.rb fibonacci.rom

  .text
  .globl _start
  .type _start, @function
_start:
  addi x5, x0, 10   # n = 10
  addi x4, x0, 0    # i = 0
  addi x1, x0, 0    # f(i) = 0
  addi x2, x0, 1    # f(i+1) = 1
loop:
  beq x4, x5, break # goto break if i == n
  add x3, x1, x2    # temp = f(i) + f(i+1)
  add x1, x2, x0    # f(i) = f(i+1)
  add x2, x3, x0    # f(i+1) = temp
  addi x4, x4, 1    # i = i + 1
  beq x0, x0, loop  # goto loop
break:
  nop
  nop
  nop
  nop
  nop
