require "./rv32sim"

decoder = Decoder.new
decoder.decode(0b1000001_10111_10011_101_10001_0110011)
printf "%07b\n", decoder.opcode
#=> 0110011
printf "%05b\n", decoder.rd
#=> 10001
printf "%03b\n", decoder.funct3
#=> 101
printf "%05b\n", decoder.rs1
#=> 10011
printf "%05b\n", decoder.rs2
#=> 10111
printf "%07b\n", decoder.funct7
#=> 1000001
