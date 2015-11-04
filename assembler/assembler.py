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
		"bclt" : Instruction.bclt,
		"bclf" : Instruction.bclf,
		"add.s" : Instruction.fadd,
		"mul.s" : Instruction.fmul,
		"inv.s" : Instruction.finv,
		"sub.s" : Instruction.fsub,
		"lw.s" : Instruction.flw,
		"sw.s" : Instruction.fsw,
		"mult" : Instruction.mult,
		"div" : Instruction.div,
		"c.eq.s" : Instruction.feq,
		"c.lt.s" : Instruction.flt,
		"c.le.s" : Instruction.fle,
		"move.s" : Instruction.fmove,
		"in" : Instruction.in_,
		"out" : Instruction.out,
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

		text_lines, data_lines = Parser.read_section(lines)
	
		with open(oc_name, "wb") as file_out:
			# build the correspondence between label and address
			(text_label_dict, text_lines) = Parser.read_label(text_lines)
			(data_label_dict, data_lines) = Parser.read_label(data_lines)

			# build header
			(header, text_lines, data_lines) = Parser.read_header(text_lines, data_lines, text_label_dict)
			file_out.write(header)

			# merge label dict
			data_label_dict = {k: v + len(text_lines) for k, v in data_label_dict.items()}
			label_dict = {k: v for d in [text_label_dict, data_label_dict] for k, v in d.items()}

			for i, line in enumerate(text_lines):
				# Each line correspond to one assembly instruction,
				# which is 32bit fixed length.
				(operation, operands) = Parser.parse_line(line)
				func = self.INST_TABLE[operation]
				bytecode = func(operands, label_dict, i)
				file_out.write(bytecode)

			for i, line in enumerate(data_lines):
				bytecode = Parser.parse_data(line)
				file_out.write(bytecode)
