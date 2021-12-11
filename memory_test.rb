require "./rv32sim"

memory = Memory.new("\x93\x00\x01\x01\x94\x00\x01\x01")
printf "%08x\n", memory.read(0)
#=> 01010093
printf "%08x\n", memory.read(4)
#=> 01010094
p memory.read(8)
