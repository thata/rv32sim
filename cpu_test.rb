require "./rv32sim"

def _add(rd, rs1, rs2)
  0b0110011 |
    (rd << 7) |
    (0x0 << 12) |
    (rs1 << 15) |
    (rs2 << 20) |
    (0x00 << 25)
end

def _sub(rd, rs1, rs2)
  0b0110011 |
    (rd << 7) |
    (0x0 << 12) |
    (rs1 << 15) |
    (rs2 << 20) |
    (0x20 << 25)
end

def _or(rd, rs1, rs2)
  0b0110011 |
    (rd << 7) |
    (0x6 << 12) |
    (rs1 << 15) |
    (rs2 << 20) |
    (0x00 << 25)
end

def _and(rd, rs1, rs2)
  0b0110011 |
    (rd << 7) |
    (0x7 << 12) |
    (rs1 << 15) |
    (rs2 << 20) |
    (0x00 << 25)
end

def _addi(rd, rs1, imm)
  0b0010011 |
    (rd << 7) |
    (0x0 << 12) |
    (rs1 << 15) |
    (imm << 20)
end

def _nop
  _addi(0, 0, 0)
end

def _beq(rs1, rs2, imm)
  imm1_4 = (imm & 0b0_0000_0001_1110) >> 1
  imm5_10 = (imm & 0b0_0111_1110_0000) >> 5
  imm11 = (imm & 0b0_1000_0000_0000) >> 11
  imm12 = (imm & 0b1_0000_0000_0000) >> 12

  0b1100011 |
    (imm11 << 7) |
    (imm1_4 << 8) |
    (0x0 << 12) |
    (rs1 << 15) |
    (rs2 << 20) |
    (imm5_10 << 25) |
    (imm12 << 31)
end

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
