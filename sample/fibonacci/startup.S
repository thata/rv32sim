.text
.globl _start
.type _start, @function

.globl _stack_top

_start:
  la sp, _stack_top
  call main
  // main から返ってきた値を x1 へ格納する
  add x1, a0, zero
  nop
  nop
  nop
  nop
  nop
