require "./rv32sim"
require "./instructions"

include Instructions

# 命令メモリ
rom = [
  _addi(1, 0, 10),
  _addi(2, 0, 20),
  _addi(3, 0, 30),
  _add(4, 1, 2), # x4 = x1 + x2
  _add(5, 4, 3), # x5 = x4 + x3
].pack("V*")

sim = Simulator.new
sim.init_inst_memory(rom)
sim.start
sim.dump_registers
