# rv32sim: RISC-V subset simulator

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](https://raw.githubusercontent.com/d0iasm/rvemu/master/LICENSE)

## 使い方

```sh
$ git clone git@github.com:thata/rv32sim.git
$ cd rv32sim
$ ruby rv32sim.rb sample/hello.rom
HELLO WORLD!!
--------------------------------------------------------------------------------
x00 = 0x0 (0)	x01 = 0x0 (0)	x02 = 0x0 (0)	x03 = 0x10000000 (268435456)
x04 = 0x0 (0)	x05 = 0xa (10)	x06 = 0x0 (0)	x07 = 0x0 (0)
x08 = 0x0 (0)	x09 = 0x0 (0)	x10 = 0x0 (0)	x11 = 0x0 (0)
x12 = 0x0 (0)	x13 = 0x0 (0)	x14 = 0x0 (0)	x15 = 0x0 (0)
x16 = 0x0 (0)	x17 = 0x0 (0)	x18 = 0x0 (0)	x19 = 0x0 (0)
x20 = 0x0 (0)	x21 = 0x0 (0)	x22 = 0x0 (0)	x23 = 0x0 (0)
x24 = 0x0 (0)	x25 = 0x0 (0)	x26 = 0x0 (0)	x27 = 0x0 (0)
x28 = 0x0 (0)	x29 = 0x0 (0)	x30 = 0x0 (0)	x31 = 0x0 (0)
--------------------------------------------------------------------------------
pc = 0x88 (136)
$
```

## サポートしてる命令
- RV32I Subset
  - add (ADD)
  - sub (SUB)
  - or (OR)
  - and (AND)
  - addi (ADD Immediate)
  - beq (Branch ==)
  - slli (Shift Left Logical Immediate)
  - lw (Load Word)
  - sw (Store Word)

