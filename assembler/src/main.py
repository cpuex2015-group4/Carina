import assembler as ass
from assembler import Parser
from assembler import FUNC_DICT
import sys

file_in = open(sys.argv[1])
file_out = open(sys.argv[1].replace(".s", ".o"), "wb")
lines = file_in.readlines()
(label_dict, lines) = ass.Parser.read_label(lines)
(header, lines) = Parser.read_header(lines, label_dict)
file_out.write(header)
for i, line in enumerate(lines):
	(operation, operands) = Parser.parse_line(line)
	func  = FUNC_DICT[operation]
	bytes = func(operands, label_dict, i)
	file_out.write(bytes)

