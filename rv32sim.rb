# RISC-V(RV32 subset) Simulator
# usage:
#   ruby rv32sim.rb sample/fibonacci.rom

class Memory
  WORD_SIZE = 4

  attr_accessor :data

  def initialize(data = nil)
    @data = data
  end

  def read(addr)
    word = @data.slice(addr, WORD_SIZE)

    # RISC-Vはリトルエンディアンなので、「V = little endian unsigned 32bit」でメモリの内容を読み込む
    word.unpack("V").first
  end

  def write(addr, word)
    data = [word].pack("V")
    @data.setbyte(addr, data.getbyte(0))
    @data.setbyte(addr + 1, data.getbyte(1))
    @data.setbyte(addr + 2, data.getbyte(2))
    @data.setbyte(addr + 3, data.getbyte(3))
  end

  def dump(out = $stdout)
    i = 0
    n_data = @data.size

    while i < n_data
      # address
      out.printf "%08x    ", i

      # data
      eom = false
      (0..3).each do |j|
        break if eom
        out.print "  " unless j == 0
        (0..3).each do |k|
          idx = i + (j * 4) + k
          b = @data.getbyte(idx)
          unless b
            eom = true
            break
          end
          out.print " " unless k == 0
          break unless b
          out.printf "%02x", b if b
        end
      end

      out.print "\n"

      i += 16
    end
  end
end

class Decoder
  attr_reader :opcode, :rd, :funct3, :rs1, :rs2, :funct7, :i_imm, :s_imm, :b_imm

  def initialize
    @opcode = nil
    @rd = nil
    @funct3 = nil
    @rs1 = nil
    @rs2 = nil
    @funct7 = nil
    @i_imm = nil
    @s_imm = nil
    @b_imm = nil
  end

  def decode(inst)
    @opcode = (inst & 0x0000007f)
    @rd = (inst & 0x00000f80) >> 7
    @funct3 = (inst & 0x00007000) >> 12
    @rs1 = (inst & 0x000f8000) >> 15
    @rs2 = (inst & 0x01f00000) >> 20
    @funct7 = if opcode == 0b0110011
                (inst & 0xfe000000) >> 25
              else
                nil
              end
    @i_imm = (inst & 0xfff00000) >> 20
    @s_imm = ((inst & 0xfe000000) >> 20) | ((inst & 0x00000f80) >> 7)
    @b_imm = ((inst & 0x80000000) >> 19) |
             ((inst & 0x00000080) << 4) |
             ((inst & 0x7e000000) >> 20) |
             ((inst & 0x00000f00) >> 7)
  end
end

class Cpu
  INST_TABLE = {
    [0b0110011, 0x0, 0x00] => :_add,
    [0b0110011, 0x0, 0x20] => :_sub,
    [0b0110011, 0x6, 0x00] => :_or,
    [0b0110011, 0x7, 0x00] => :_and,
    [0b0010011, 0x0, nil] => :_addi,
    [0b1100011, 0x0, nil] => :_beq
  }

  attr_accessor :pc
  attr_reader :x_registers, :inst_memory, :data_memory

  def initialize
    @pc = 0                   # プログラムカウンタ
    @x_registers = [0] * 32   # レジスタ
    @decoder = Decoder.new
    @inst_memory = Memory.new # 命令メモリ
    @data_memory = Memory.new( # データメモリ
      ("\x00" * 256).b
    )
  end

  def init_inst_memory(data)
    @inst_memory.data = data
  end

  def run
    inst = fetch

    # 命令メモリの範囲外に来たら false を返して処理を終える
    return false unless inst

    decode(inst)
    execute
    true
  end

  def fetch
    @inst_memory.read(@pc)
  end

  def decode(inst)
    @decoder.decode(inst)
  end

  def execute
    key = [@decoder.opcode, @decoder.funct3, @decoder.funct7]
    inst_symbol = INST_TABLE[key]
    send inst_symbol
  end

  ### Instructions

  def _add
    rd = @decoder.rd
    rs1 = @decoder.rs1
    rs2 = @decoder.rs2
    @x_registers[rd] = @x_registers[rs1] + @x_registers[rs2]
    @pc = @pc + 4
  end

  def _sub
    rd = @decoder.rd
    rs1 = @decoder.rs1
    rs2 = @decoder.rs2
    @x_registers[rd] = @x_registers[rs1] - @x_registers[rs2]
    @pc = @pc + 4
  end

  def _or
    rd = @decoder.rd
    rs1 = @decoder.rs1
    rs2 = @decoder.rs2
    @x_registers[rd] = @x_registers[rs1] | @x_registers[rs2]
    @pc = @pc + 4

    @x_registers[@rd] = @x_registers[@rs1] | @x_registers[@rs2]
    @pc = @pc + 4
  end

  def _and
    rd = @decoder.rd
    rs1 = @decoder.rs1
    rs2 = @decoder.rs2
    @x_registers[rd] = @x_registers[rs1] & @x_registers[rs2]
    @pc = @pc + 4
  end

  def _addi
    rd = @decoder.rd
    rs1 = @decoder.rs1
    i_imm = @decoder.i_imm

    minus_flg = (i_imm & 0b100000000000) >> 11
    imm = if minus_flg == 1
            # TODO もっといい感じに書きたい
            imm = (0b1000000000000 - i_imm) * -1
          else
            imm = i_imm
          end
    @x_registers[rd] = @x_registers[rs1] + imm
    @pc = @pc + 4
  end

  def _beq
    rd = @decoder.rd
    rs1 = @decoder.rs1
    rs2 = @decoder.rs2
    b_imm = @decoder.b_imm

    minus_flg = (b_imm & 0b1000000000000) >> 12
    imm = if minus_flg == 1
            # TODO もっといい感じに書きたい
            imm = (0b10000000000000 - b_imm) * -1
          else
            imm = b_imm
          end
    @pc = if @x_registers[rs1] == @x_registers[rs2]
            @pc + imm
          else
            @pc + 4
          end
  end
end

class Simulator
  def initialize
    @cpu = Cpu.new
  end

  def init_inst_memory(data)
    @cpu.init_inst_memory(data)
  end

  def start
    loop do
      @cpu.run || break
    end
  end

  def dump_registers
    puts "-" * 80

    for i in 0..7
      for j in 0..3
        print "\t" unless j == 0
        n = (i * 4) + j
        print sprintf "x%02d = 0x%x (%d)", n, @cpu.x_registers[n], @cpu.x_registers[n]
      end
      print "\n"
    end

    puts "-" * 80
    puts sprintf "pc = 0x%x (%d)", @cpu.pc, @cpu.pc
  end

  def dump_data_memory
    puts "-" * 80
    @cpu.data_memory.dump
  end
end

if $0 == __FILE__
  sim = Simulator.new
  rom = File.binread(ARGV.shift)
  sim.init_inst_memory(rom)
  sim.start
  sim.dump_registers
  sim.dump_data_memory
end
