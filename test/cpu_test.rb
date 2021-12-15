require "test_helper"
require "rv32sim"

class CpuTest < Test::Unit::TestCase
  include Instructions

  def test_add
    cpu = Cpu.new
    cpu.x_registers[2] = 1
    cpu.x_registers[3] = 2

    rom = [
      _add(1, 2, 3)
    ].pack("V*")
    cpu.init_inst_memory(rom)
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
    ].pack("V*")
    cpu.init_inst_memory(rom)
    cpu.run

    assert_equal 4, cpu.pc
    assert_equal 0xff000000, cpu.x_registers[1]
  end

  def test_addi
    cpu = Cpu.new

    rom = [
      _addi(1, 2, 10),
      _addi(1, 1, -10)
    ].pack("V*")
    cpu.init_inst_memory(rom)

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

  def test_beq
    cpu = Cpu.new

    # x1 == x2 の場合
    cpu.pc = 0
    cpu.x_registers[1] = 1
    cpu.x_registers[2] = 1
    rom = [
      _beq(1, 2, 12)
    ].pack("V*")
    cpu.init_inst_memory(rom)
    cpu.run
    assert_equal 12, cpu.pc

    # x1 != x2 の場合
    cpu.pc = 0
    cpu.x_registers[1] = 1
    cpu.x_registers[2] = 2
    rom = [
      _beq(1, 2, 12)
    ].pack("V*")
    cpu.init_inst_memory(rom)
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
    ].pack("V*")
    cpu.init_inst_memory(rom)
    cpu.run
    assert_equal 4, cpu.pc
  end

  def test_run
    data = [
      _addi(1, 0, 10),
      _addi(1, 1, 20),
      _beq(0, 0, -8)
    ].pack("V*")

    cpu = Cpu.new
    cpu.init_inst_memory(data)

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
    # cpu.decode(0b100000000001_10011_010_10001_0000011)

    # _sw
    # cpu.decode(0b100000000001_10011_010_10001_0100011)
  end
end
