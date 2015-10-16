#!/usr/bin/env python
# coding: utf-8

import assembler as ass
from assembler import Parser
from assembler import FUNC_DICT
import sys

def assemble(filename):
    with open(filename) as file_in:
		lines = file_in.readlines()

    with open(filename.replace(".s", ".o"), "wb") as file_out:
		(label_dict, lines) = ass.Parser.read_label(lines)
		(header, lines) = Parser.read_header(lines, label_dict)
		file_out.write(header)
		for i, line in enumerate(lines):
			(operation, operands) = Parser.parse_line(line)
			func = FUNC_DICT[operation]
			bytes = func(operands, label_dict, i)
			file_out.write(bytes)

if __name__ == "__main__":
	filename = sys.argv[1]
	assemble(filename)
