module Instructions
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

  def _lw(rd, rs1, imm)
    0b0000011 |
      (rd << 7) |
      (0x2 << 12) |
      (rs1 << 15) |
      (imm << 20)
  end

  def _sw(rs1, rs2, imm)
    imm0_4 = imm & 0b0000_0001_1111
    imm5_11 = (imm & 0b1111_1110_0000) >> 5

    0b0100011 |
      (imm0_4 << 7) |
      (0x2 << 12) |
      (rs1 << 15) |
      (rs2 << 20) |
      (imm5_11 << 25)
  end

  def _auipc(rd, imm)
    imm12_31 = imm

    0b0010111 |
      (rd << 7) |
      imm << 12
  end

  def _jalr(rd, rs1, imm)
    0b1100111 |
      (rd << 7) |
      (0x0 << 12) |
      (rs1 << 15) |
      (imm << 20)
  end
end
