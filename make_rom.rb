# ruby make_rom.rb > ./rom

require "./instructions"

include Instructions

# フィボナッチ数の第10項を求めプログラム
# f(i): x1
# f(i+1): x2
# temp: x3
# i: x4
# n: x5
rom = [
  _addi(5, 0, 10),   # n = 10
  _addi(4, 0, 0),    # i = 0
  _addi(1, 0, 0),    # f(i) = 0
  _addi(2, 0, 1),    # f(i+1) = 1
  _beq(4, 5, 24),    # LOOP: goto BREAK if i == n
  _add(3, 1, 2),     # temp = f(i) + f(i+1)
  _addi(1, 2, 0),    # f(i) = f(i+1)
  _addi(2, 3, 0),    # f(i+1) = temp
  _addi(4, 4, 1),    # i = i + 1
  _beq(0, 0, -20),   # goto LOOP
  _nop,              # BREAK:
].pack("V*")

print rom
