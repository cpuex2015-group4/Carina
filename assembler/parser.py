#!/usr/bin/env python
# coding: utf-8

from enum import Enum
import utils
import re

class Operandtype(Enum):
	"""
	An Enum representing for operand format.
	"""
	REGISTER_DIRECT = 1     # %reg
	REGISTER_INDIRECT = 2   # $disp(%reg)
	IMMEDIATE = 3           # $imm
	SHAMT = 4               # shamt (cf. MIPS docs)
	ADDRESS = 5             # addr
	LABEL_RELATIVE = 6      # label (PC-relative)
	LABEL_ABSOLUTE = 7      # label (absolute)

class Parser:
	"""
	A class representing for Carina assembly parser.
	"""

	@staticmethod
	def read_header(lines, label_dict):
		"""
		Returns
		----------
		header: bytes
			bytecodes of header for the executable

		new_lines: list
			assembly lines removed of pseudo instruction
		"""
		new_lines = []
		header = ""
		header += "CARN"
		header += utils.bin2bytes(format(0, "032b"))
		header += utils.bin2bytes(format(0, "032b"))
		offset = 0
		for line in lines:
			if ".globl" in line:
				main_func_name = line.replace(".globl", "").strip()
				offset = label_dict[main_func_name]
				header += utils.bin2bytes(format(offset * 4, "032b"))
			elif(not ((".text" in line) or (".data" in line))):
				new_lines.append(line)
		return (header, new_lines)

	#return : (dict{label_name : line_idx}, new_lines(<- not contain label))
	@staticmethod
	def read_label(lines):
		label_dict = {}
		new_lines = []
		line_num_offset = 0
		for i,line in enumerate(lines):
			if (".data" in line) or (".text" in line) or (".globl" in line):
				new_lines.append(line)
				line_num_offset -= 1
				continue
			#ignore comment
			line = re.sub(r"#.*", "", line)
			line = line.strip()
			if line == "":
				line_num_offset -= 1
				continue
			if ":" in line:
				label_name = line.split(":")[0].strip()
				label_dict[label_name] = i + line_num_offset
				line_num_offset -= 1
			else:
				new_lines.append(line)
		return label_dict, new_lines

#return (operation, operands[])
#line does not contain label
	@staticmethod
	def parse_line(line):
		line = line.strip()
		tmp = line.split(" ", 1)
		operation = tmp[0]
		try:
			operands = tmp[1].replace(" ", "").split(",")
		except Exception:
			operands = None
		return (operation, operands)

	@staticmethod
	def parse_operand(operand, operand_type, label_dict=None, line_num=0):
		if operand_type == Operandtype.REGISTER_DIRECT:
			register_bin = utils.reg2bin(operand)
			return (register_bin, None)
		elif operand_type == Operandtype.REGISTER_INDIRECT:
			tmp = operand.split("(")
			if tmp[0] == "":
				immediate_bin = utils.imm2bin(0)
			else:
				immediate_bin = utils.imm2bin(int(tmp[0]))
			register_bin = utils.reg2bin(tmp[1][0:-1])
			return (register_bin, immediate_bin)
		elif operand_type == Operandtype.IMMEDIATE:
			immediate_bin = utils.imm2bin(int(operand.replace("$", "")))
			return (None, immediate_bin)
		elif operand_type == Operandtype.SHAMT:
			shamt_bin = utils.shamt2bin(int(operand.replace("$", "")))
			return (None, shamt_bin)
		elif operand_type == Operandtype.ADDRESS:
			address_bin = utils.address2bin(int(operand))
			return (None, address_bin)
		elif operand_type == Operandtype.LABEL_RELATIVE:
			target_line_num = label_dict[operand]
			offset = target_line_num - line_num
			offset_bin = utils.offset2bin(offset)
			return (None, offset_bin)
		elif operand_type == Operandtype.LABEL_ABSOLUTE:
			target_line_num = label_dict[operand]
			return (None, format(4 * target_line_num, "026b"))

