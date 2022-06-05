# ruby sample/make_rom.rb > sample/4649.rom

require_relative "../instructions"

include Instructions

# ここに命令を並べる
rom = [
  _addi(1, 0, 0x46), # x1 = ヨロ(46)
  _addi(2, 0, 0x49), # x2 = シク(49)
  _nop,
  _nop,
  _nop,
  _nop,
  _nop,
].pack("l*")

print rom
