require "test_helper"
require "rv32sim"

class DecoderTest < Test::Unit::TestCase
  include Instructions

  def test_docode
    decoder = Decoder.new

    # R形式
    decoder.decode(0b1000001_10111_10011_101_10001_0110011)
    assert_equal decoder.opcode, 0b0110011
    assert_equal decoder.rd, 0b10001
    assert_equal decoder.funct3, 0b101
    assert_equal decoder.rs1, 0b10011
    assert_equal decoder.rs2, 0b10111
    assert_equal decoder.funct7, 0b1000001

    # I形式
    decoder.decode(0b100000000001_10011_101_10001_0010011)
    assert_equal decoder.opcode, 0b0010011
    assert_equal decoder.rd, 0b10001
    assert_equal decoder.funct3, 0b101
    assert_equal decoder.rs1, 0b10011
    assert_equal decoder.i_imm, 0b100000000001

    # S形式
    decoder.decode(0b1000001_10111_10011_101_10001_0100011)
    assert_equal decoder.opcode, 0b0100011
    assert_equal decoder.funct3, 0b101
    assert_equal decoder.rs1, 0b10011
    assert_equal decoder.rs2, 0b10111
    assert_equal decoder.s_imm, 0b100000110001

    # B形式
    decoder.decode(0b1_100001_10111_10011_101_1001_1_1100011)
    assert_equal decoder.opcode, 0b1100011
    assert_equal decoder.funct3, 0b101
    assert_equal decoder.rs1, 0b10011
    assert_equal decoder.rs2, 0b10111
    assert_equal decoder.b_imm, 0b1110000110010
  end
end
