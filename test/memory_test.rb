require "test_helper"
require "rv32sim"

class MemoryTest < Test::Unit::TestCase
  def test_read
    ram = Memory.new("\x93\x00\x01\x01\x94\x00\x01\x01")

    addr = 0
    assert_equal 0x01010093, ram.read(addr)

    addr = 4
    assert_equal 0x01010094, ram.read(addr)

    # メモリからはみ出た場合は nil を返す
    addr = 8
    assert_equal nil, ram.read(addr)

    # メモリから部分的にはみ出た場合も nil を返す
    addr = 7
    assert_equal nil, ram.read(addr)
  end

  def test_set_data
    # ram = Memory.new

    # addr = 0
    # assert_equal 0x00000000, ram.read(addr)

    # ram.data = "\x93\x00\x01\x01\x94\x00\x01\x01"

    # addr = 0
    # assert_equal 0x01010093, ram.read(addr)
  end
end