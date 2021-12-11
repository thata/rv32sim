require "./rv32sim"
require "./instructions"

include Instructions

cpu = Cpu.new
cpu.x_registers[1] = 10
cpu.x_registers[2] = 20
cpu.x_registers[3] = 30

# 命令メモリをセット
rom = [
  _add(4, 1, 2), # x4 = x1 + x2
  _add(5, 4, 3), # x5 = x4 + x3
].pack("V*")

cpu.init_inst_memory(rom)

# 実行前
puts cpu.pc
#=> 0
puts cpu.x_registers[4]
#=> 0
puts cpu.x_registers[5]
#=> 0

cpu.run # 1つめの命令を実行
cpu.run # 2つめの命令を実行

# 実行後
puts cpu.pc
#=> 8
puts cpu.x_registers[4]
#=> 30
puts cpu.x_registers[5]
#=> 60
