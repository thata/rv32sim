class Memory
  WORD_SIZE = 4

  attr_accessor :data

  def initialize(data = nil)
    # バイナリデータとして扱いたいので ASCII-8BIT エンコーディングへ変換
    @data = data.b
  end

  # 指定したアドレスから1ワード（4バイト）のデータを読み込む
  def read(addr)
    word = @data.slice(addr, WORD_SIZE)

    # 「signed int32」でメモリの内容を読み込む
    # see: https://docs.ruby-lang.org/ja/latest/doc/pack_template.html
    word.unpack1("l")
  end

  # 指定したアドレスへ1ワード（4バイト）のデータを書き込む
  def write(addr, word)
    # 「signed int32」でメモリへ書き込む
    @data[addr, 4] = [word].pack("l")
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

	# NOP命令（no operation 何も行わない命令）かどうかを判定（あとで使う）
  def nop?
    @opcode == 0b0010011 &&
      @funct3 == 0 &&
      @rd == 0 &&
      @rs1 == 0 &&
      @i_imm == 0
  end
end

class Cpu
  INST_TABLE = {
    [0b0110011, 0x0, 0x00] => :_add,
    [0b0110011, 0x0, 0x20] => :_sub,
    [0b0110011, 0x6, 0x00] => :_or,
    [0b0110011, 0x7, 0x00] => :_and,
    [0b0010011, 0x0, nil] => :_addi,
		[0b0010011, 0x1, nil] => :_slli,
    [0b1100011, 0x0, nil] => :_beq,
    [0b0000011, 0x2, nil] => :_lw,
    [0b0100011, 0x2, nil] => :_sw
  }

  attr_accessor :pc
  attr_reader :x_registers, :memory

  def initialize
    @pc = 0                   # プログラムカウンタ
    @x_registers = [0] * 32   # レジスタ
		class << @x_registers
      # x0は常に0を返す
      def [](nth)
        nth == 0 ? 0 : super
      end
    end

    @decoder = Decoder.new
    @memory = Memory.new(     # メモリ
      ("\x00" * 512).b
    )
    @nop_count = 0
  end

  def init_memory(data)
    @memory.data[0, data.size] = data
  end

  def run
    inst = fetch

    decode(inst)

    # NOPが5回来たら処理を終える
    return false if @nop_count >= 5

    execute
    true
  end

  def fetch
    @memory.read(@pc)
  end

  def decode(inst)
    @decoder.decode(inst)
    if @decoder.nop?
      @nop_count += 1
    else
      @nop_count = 0
    end
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

	def _slli
    rd = @decoder.rd
    rs1 = @decoder.rs1
    i_imm = @decoder.i_imm
    @x_registers[rd] = @x_registers[rs1] << (i_imm & 0b11111)
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

  def _lw
    rd = @decoder.rd
    rs1 = @decoder.rs1
    imm = @decoder.i_imm
    @x_registers[rd] = @memory.read(@x_registers[rs1] + imm)
    @pc = @pc + 4
  end

  def _sw
    rs1 = @decoder.rs1
    rs2 = @decoder.rs2
    imm = @decoder.s_imm
    @memory.write(@x_registers[rs1] + imm, @x_registers[rs2])
    @pc = @pc + 4
  end
end

class Simulator
  def initialize
    @cpu = Cpu.new
  end

  def init_memory(data)
    @cpu.init_memory(data)
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
end

if $0 == __FILE__
  sim = Simulator.new
  mem = File.binread(ARGV.shift)
  sim.init_memory(mem)
  sim.start
  sim.dump_registers
end
