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
		entry_point = "_min_caml_start"

		if entry_point not in label_dict:
			raise ValueError("program should have entry point named {}".format(entry_point))

		epaddr = label_dict[entry_point] * 4

		header = "".join([
			# magic number
			"CARN",
			# text size
			utils.bin2bytes(format(0, "032b")),
			# data size
			utils.bin2bytes(format(0, "032b")),
			# entry point
			utils.bin2bytes(format(epaddr, "032b"))])
		new_lines = filter(lambda l:
				".text" not in l and
				".data" not in l and
				".globl" not in l,
				lines)

		return (header, new_lines)

	@staticmethod
	def read_label(lines):
		"""
		Analyze assembly lines and build correspondence between label and offset.

		Parameters
		----------
		lines: str list
			assembly lines

		Returns
		----------
		label_dict: dict
			correspondance between label and offset in .text section

		new_lines: str list
			assembly lines removed of the lines only consists of label
		"""
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

	@staticmethod
	def parse_line(line):
		"""
		Parse assembly one line and split into the pair of instruction and operands.

		Parameters
		----------
		line: str
			assembly line (without label)

		Returns
		----------
		inst: str
			instruction mnemonic

		operands: str list
			list of operands
		"""

		match = re.findall(r"\s*([a-z]+?)\s+(.*)", line)

		if len(match) == 0:
			return (line, [])
		else:
			return (match[0][0], match[0][1].split(", "))

	@staticmethod
	def parse_operand(operand, operand_type, label_dict=None, line_num=0):
		"""
		Receive operand and its type, then return the binary representation of operand.

		Parameters
		----------
		operand: str
			assembly representation of operand

		operand_type: Operanttype
			operand type

		label_dict: dict
			table of correspondence between label and address

		line_num: int
			line number (similar with .text address/offset)

		Returns
		----------
		bin_reg: byte
			binary representation of register

		bin_imm: byte
			binary representation of immediate (shamt, funct, etc.)
		"""
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

