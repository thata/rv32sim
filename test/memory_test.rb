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
    ram = Memory.new("\x93\x00\x01\x01\x94\x00\x01\x01")

    # いい感じに書き込めること
    assert_equal 0x01010093, ram.read(0)
    assert_equal 0x01010094, ram.read(4)

    ram.write(0, 0x01010095)
    ram.write(4, 0x01010096)

    assert_equal 0x01010095, ram.read(0)
    assert_equal 0x01010096, ram.read(4)
  end

  def test_dump
    # 16バイトぴったりの場合
    ram = Memory.new(
      "\x01" + ("\x00" * 14) + "\x01"
    )
    buff = StringIO.new
    ram.dump(buff)
    assert_equal(
      "00000000    01 00 00 00  00 00 00 00  00 00 00 00  00 00 00 01\n",
      buff.string
    )

    # 16バイトに満たない場合
    ram = Memory.new(
      "\x01" + ("\x00" * 3) + "\x01"
    )
    buff = StringIO.new
    ram.dump(buff)
    assert_equal(
      "00000000    01 00 00 00  01\n",
      buff.string
    )

    # 複数行の場合
    ram = Memory.new(
      "\x01" + ("\x00" * 14) + "\x01" + "\x11" + ("\x00" * 14) + "\x11"
    )
    buff = StringIO.new
    ram.dump(buff)
    assert_equal(
      "00000000    01 00 00 00  00 00 00 00  00 00 00 00  00 00 00 01\n00000010    11 00 00 00  00 00 00 00  00 00 00 00  00 00 00 11\n",
      buff.string
    )
  end
end