require_relative "test_helper"
require_relative "../rv32sim"

class CpuTest < Test::Unit::TestCase
  include Instructions

  def test_add
    cpu = Cpu.new
    cpu.x_registers[2] = 1
    cpu.x_registers[3] = 2

    rom = [
      _add(1, 2, 3)
    ].pack("l*")
    cpu.init_memory(rom)
    cpu.run

    assert_equal 4, cpu.pc
    assert_equal 3, cpu.x_registers[1]
  end

  def test_and
    cpu = Cpu.new
    cpu.x_registers[2] = 0xff00ff00
    cpu.x_registers[3] = 0xffff0000

    rom = [
      _and(1, 2, 3)
    ].pack("l*")
    cpu.init_memory(rom)
    cpu.run

    assert_equal 4, cpu.pc
    assert_equal 0xff000000, cpu.x_registers[1]
  end

  def test_or
    cpu = Cpu.new
    cpu.x_registers[2] = 0xff00ff00
    cpu.x_registers[3] = 0x00ff00f0

    rom = [
      _or(1, 2, 3)
    ].pack("l*")
    cpu.init_memory(rom)
    cpu.run

    assert_equal 4, cpu.pc
    assert_equal 0xfffffff0, cpu.x_registers[1]
  end

  def test_addi
    cpu = Cpu.new

    rom = [
      _addi(1, 2, 10),
      _addi(1, 1, -10)
    ].pack("l*")
    cpu.init_memory(rom)

    # imm が正の数の場合
    cpu.x_registers[2] = 5
    cpu.run
    assert_equal 4, cpu.pc
    assert_equal 15, cpu.x_registers[1]

    # imm が負の数の場合
    cpu.run
    assert_equal 8, cpu.pc
    assert_equal 5, cpu.x_registers[1]
  end

  def test_lui
    cpu = Cpu.new

    rom = [
      _lui(1, 0x7CAFE),
      _lui(2, 0x8CAFE),
    ].pack("l*")
    cpu.init_memory(rom)

    cpu.run
    cpu.run

    assert_equal 2091900928, cpu.x_registers[1]
    assert_equal -1934630912, cpu.x_registers[2]
  end

  def test_auipc
    # imm が正の数の場合
    rom = [
      _nop,
      _nop,
      _nop,
      _auipc(1, 0x7FFFF)
    ].pack("l*")
    cpu = Cpu.new
    cpu.init_memory(rom)
    cpu.x_registers[1] = 0
    cpu.run
    cpu.run
    cpu.run
    cpu.run
    assert_equal 16, cpu.pc
    assert_equal ("%05x" % 0x7FFFF00C), ("%05x" % cpu.x_registers[1])

    # imm が負の数の場合
    rom = [
      _auipc(1, 0xFFFFF)
    ].pack("l*")
    cpu = Cpu.new
    cpu.init_memory(rom)
    cpu.x_registers[1] = 0
    cpu.run
    assert_equal 4, cpu.pc
    assert_equal (-4096), cpu.x_registers[1]
  end

  def test_beq
    cpu = Cpu.new

    # x1 == x2 の場合
    cpu.pc = 0
    cpu.x_registers[1] = 1
    cpu.x_registers[2] = 1
    rom = [
      _beq(1, 2, 12)
    ].pack("l*")
    cpu.init_memory(rom)
    cpu.run
    assert_equal 12, cpu.pc

    # x1 != x2 の場合
    cpu.pc = 0
    cpu.x_registers[1] = 1
    cpu.x_registers[2] = 2
    rom = [
      _beq(1, 2, 12)
    ].pack("l*")
    cpu.init_memory(rom)
    cpu.run
    assert_equal 4, cpu.pc

    # 負数の分岐
    cpu.pc = 36
    cpu.x_registers[1] = 1
    cpu.x_registers[2] = 1
    rom = [
      _nop,
      _nop,
      _nop,
      _nop,
      _nop,
      _nop,
      _nop,
      _nop,
      _nop,
      _beq(1, 2, -32) # <= address = 36
    ].pack("l*")
    cpu.init_memory(rom)
    cpu.run
    assert_equal 4, cpu.pc
  end

  def test_jal
    cpu = Cpu.new

    rom = [
      _addi(29, 0, 10), # x29 = 10
      _jal(1, 40),      # call foo （ x1 = pc+4; pc = pc + 40 ）
      _nop,
      # bar
      _add(31, 29, 30), # x31 = x29 + x30
      _jalr(0, 1, 0),   # ret
      _nop,
      _nop,
      _nop,
      _nop,
      _nop,
      _nop,
      # foo
      _addi(30, 0, 20), # x30 = 20
      _addi(2, 1, 0),   # x2 = x1 （戻り先を退避）
      _jal(1, -40),     # call bar （x1 = pc+4; pc = pc - 40）
      _addi(1, 2, 0),   # x1 = x2 （戻り先を復元）
      _jalr(0, 1, 0)    # ret
    ].pack("l*")
    cpu.init_memory(rom)

    cpu.run # x29 = 10
    cpu.run # call foo （ x1 = pc+4; pc = pc + 40 ）

    assert_equal 44, cpu.pc
    assert_equal 8, cpu.x_registers[1]

    cpu.run # x30 = 20
    cpu.run # x2 = x1
    cpu.run # call bar

    assert_equal 12, cpu.pc

    cpu.run # x30 = 20
    cpu.run # ret

    assert_equal 56, cpu.pc

    cpu.run # x1 = x2
    cpu.run # ret

    assert_equal 8, cpu.pc
    assert_equal 30, cpu.x_registers[31]
  end

  def test_jalr
    cpu = Cpu.new

    # XXX: 行き当たりばったりに書いたのでゴチャゴチャしてる...
    rom = [
      _addi(2, 0, 40),  # x2 = foo
      _jalr(1, 2, 0),   # call foo （ t=pc+4; pc=(x2+0) & ~1; x1=t ）
      _add(31, 29, 30), # x31 = x29 + x30
      _nop,
      _jalr(1, 31, -5), # call bar （ t=pc+4; pc=(x31-5)&~1）; x1=t ）
      _addi(28, 0, 49), # x28 = 49
      # bar:
      _addi(27, 0, 46), # x27 = 46
      _jalr(0, 1, 0),   # ret
      _nop,
      _nop,
      # foo:
      _addi(29, 0, 10), # x29 = 10
      _addi(30, 0, 20), # x30 = 20
      _jalr(0, 1, 0)    # ret
    ].pack("l*")
    cpu.init_memory(rom)

    cpu.run # x2 = 40
    cpu.run # jalr x1, x2, 0

    assert_equal 40, cpu.pc
    assert_equal 8, cpu.x_registers[1]

    cpu.run # x29 = 10
    cpu.run # x30 = 20
    cpu.run # ret

    assert_equal 8, cpu.pc

    cpu.run # x31 = x29 + x30

    assert_equal 30, cpu.x_registers[31]

    cpu.run # nop
    cpu.run # jalr x1, x31, -5

    assert_equal 24, cpu.pc
    assert_equal 20, cpu.x_registers[1]

    cpu.run # x27 = 46
    cpu.run # ret
    cpu.run # x28 = 49

    assert_equal 24, cpu.pc
    assert_equal 46, cpu.x_registers[27]
    assert_equal 49, cpu.x_registers[28]
  end

  def test_sw_lw
    cpu = Cpu.new

    rom = [
      _addi(1, 0, 0x16),   # x1 = 0x16
      _addi(2, 0, 0xFF),   # x2 = 0xFF
      _sw(1, 2, 0),        # M[x1] = x2
      _lw(3, 1, 0),        # x3 = M[x1]
      0                    # （ここに 0xFF が格納される）
    ].pack("l*")
    cpu.init_memory(rom)

    cpu.run
    cpu.run
    cpu.run
    cpu.run

    assert_equal 0x16, cpu.x_registers[1]
    assert_equal 0xff, cpu.x_registers[2]
    assert_equal 0xff, cpu.x_registers[3]
  end

  def test_run
    data = [
      _addi(1, 0, 10),
      _addi(1, 1, 20),
      _beq(0, 0, -8)
    ].pack("l*")

    cpu = Cpu.new
    cpu.init_memory(data)

    # x1 の初期値は 0
    assert_equal 0, cpu.x_registers[1]

    cpu.run

    assert_equal 4, cpu.pc
    assert_equal 10, cpu.x_registers[1]

    cpu.run

    assert_equal 8, cpu.pc
    assert_equal 30, cpu.x_registers[1]

    cpu.run

    assert_equal 0, cpu.pc
  end

  def test_instructions
    # _add
    assert_equal 0b0000000_10001_10001_000_10001_0110011, _add(17, 17, 17)

    # _sub
    assert_equal 0b0100000_10111_10011_000_10001_0110011, _sub(17, 19, 23)

    # _and
    assert_equal 0b0000000_10111_10011_111_10001_0110011, _and(17, 19, 23)

    # _or
    assert_equal 0b0000000_10111_10011_110_10001_0110011, _or(17, 19, 23)

    # _addi
    assert_equal 0b100000000001_10011_000_10001_0010011, _addi(17, 19, 0x801)

    # _beq
    assert_equal 0b1_100001_10111_10011_000_1001_1_1100011, _beq(19, 23, 0b1_1100001_1001_0)

    # _lw
    assert_equal 0b100000000001_10011_010_10001_0000011, _lw(17, 19, 0b1000_0000_0001)

    # _sw
    assert_equal 0b1000001_10111_10011_010_10001_0100011, _sw(19, 23, 0b1000_0011_0001)
  end

  def test_x0_returns_zero
    cpu = Cpu.new

    rom = [
      _addi(1, 0, 10),   # x1 = 10
      _addi(2, 0, 20),   # x2 = 20
      _add(3, 1, 2),     # x3 = x1 + x2
      _add(0, 1, 2),     # x0 = x1 + x2
    ].pack("l*")
    cpu.init_memory(rom)

    cpu.run
    cpu.run
    cpu.run
    cpu.run

    assert_equal 30, cpu.x_registers[3]
    assert_equal 0, cpu.x_registers[0]
  end
end
