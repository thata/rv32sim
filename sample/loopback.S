# loopback
#
# $ riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wl,-Ttext=0x00 -nostdlib -o loopback.elf loopback.S
# $ riscv64-unknown-elf-objcopy -O binary loopback.elf loopback.rom
# $ ruby rv32sim.rb loopback.rom

  .text
  .globl _start
  .type _start, @function
_start:
  // シリアル通信の送受信レジスタのアドレス ( 0x10000000 ) を gp レジスタにセット
  // 1024を18ビットシフトさせて 0x10000000 を作成する
  addi gp, zero, 1024
  slli gp, gp, 18
loop:
  // 無限ループなので、終了させる場合は Ctrl-c で
  lw a0, 0(gp)
  sw a0, 0(gp)
  beq zero, zero, loop
