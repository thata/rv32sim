# hello
#
# $ riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wl,-Ttext=0x00 -nostdlib -o hello.elf hello.S
# $ riscv64-unknown-elf-objcopy -O binary hello.elf hello.rom
# $ ruby rv32sim.rb hello.rom

  .text
  .globl _start
  .type _start, @function
_start:
  // シリアル通信の送受信レジスタのアドレス ( 0x10000000 ) を gp レジスタにセット
  // 1024を18ビットシフトさせて 0x10000000 を作成する
  addi gp, zero, 1024
  slli gp, gp, 18

  addi t0, zero, 'H'
  sw t0, 0(gp)
  addi t0, zero, 'E'
  sw t0, 0(gp)
  addi t0, zero, 'L'
  sw t0, 0(gp)
  addi t0, zero, 'L'
  sw t0, 0(gp)
  addi t0, zero, 'O'
  sw t0, 0(gp)
  addi t0, zero, ' '
  sw t0, 0(gp)
  addi t0, zero, 'W'
  sw t0, 0(gp)
  addi t0, zero, 'O'
  sw t0, 0(gp)
  addi t0, zero, 'R'
  sw t0, 0(gp)
  addi t0, zero, 'L'
  sw t0, 0(gp)
  addi t0, zero, 'D'
  sw t0, 0(gp)
  addi t0, zero, '!'
  sw t0, 0(gp)
  addi t0, zero, '!'
  sw t0, 0(gp)
  addi t0, zero, '\n'
  sw t0, 0(gp)
  nop
  nop
  nop
  nop
  nop
