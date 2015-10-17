#!/usr/bin/env python
# coding: utf-8

from inst import Instruction
from parser import Parser

class Assembler:
	"""
	A class representing for the assembler for Carina architecture.
	"""

	"""
	Table which returns the instance of instruction respond to assembly-mnemonic.
	"""
	INST_TABLE = {
		"add" : Instruction.add,
		"addi" : Instruction.addi,
		"and" : Instruction.and_,
		"andi" : Instruction.andi,
		"beq" : Instruction.beq,
		"bne" : Instruction.bne,
		"j" : Instruction.j,
		"jal" : Instruction.jal,
		"jr" : Instruction.jr,
		"lw" : Instruction.lw,
		"nor" : Instruction.nor,
		"or" : Instruction.or_,
		"ori" : Instruction.ori,
		"slt" : Instruction.slt,
		"slti" : Instruction.slti,
		"sll" : Instruction.sll,
		"srl" : Instruction.srl,
		"sw" : Instruction.sw,
		"sub" : Instruction.sub,
		"move" : Instruction.move,
		"subi" : Instruction.subi,
		"li" : Instruction.li,
		"hlt" : Instruction.hlt,
	}

	def assemble(self, filename):
		"""
		Assemble the given file.

		Parameters
		----------
		filename: str
		    the file name of file to be assembled

		"""
		oc_name = filename.replace(".s", ".o")

		with open(filename) as file_in:
			lines = file_in.readlines()
	
		with open(oc_name, "wb") as file_out:
			# build the correspondence between label and address
			(label_dict, lines) = Parser.read_label(lines)

			# build header
			(header, lines) = Parser.read_header(lines, label_dict)
			file_out.write(header)

			for i, line in enumerate(lines):
				# Each line correspond to one assembly instruction,
				# which is 32bit fixed length.
				(operation, operands) = Parser.parse_line(line)
				func = self.INST_TABLE[operation]
				bytecode = func(operands, label_dict, i)
				file_out.write(bytecode)
