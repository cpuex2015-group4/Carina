import assembler as ass
from assembler import Parser
from assembler import FUNC_DICT

file_in = open("sort.s")
file_out = open("debug.o", "wb")
lines = file_in.readlines()
label_dict = ass.label_dict(lines)
lines = ass.remove_label(lines)
for i, line in enumerate(lines):
  (operation, operands) = Parser.parse_line(line)
  func  = FUNC_DICT[operation]
  print(operation, operands),
  bytes = func(operands, label_dict, (i + 1))
  file_out.write(bytes)
#print(ass.hex2bin("11000005"))
