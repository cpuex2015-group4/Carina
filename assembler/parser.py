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
	def read_header(text_lines, data_lines, label_dict):
		"""
		Returns
		----------
		header: bytes
			bytecodes of header for the executable

		new_text_lines: list
			assembly .text lines removed of pseudo instruction

		new_data_lines: list
			assembly .data lines removed of pseudo instruction
		"""
		entry_point = "_min_caml_start"

		if entry_point not in label_dict:
			raise ValueError("program should have entry point named {}".format(entry_point))

		epaddr = label_dict[entry_point]

		new_text_lines = filter(lambda l:
				".text" not in l and
				".globl" not in l,
				text_lines)

		new_data_lines = filter(lambda l: ".data" not in l, data_lines)

		header = "".join([
			# magic number
			"CARN",
			# text size
			utils.bin2bytes(format(len(new_text_lines), "032b")),
			# data size
			utils.bin2bytes(format(len(new_data_lines), "032b")),
			# entry point
			utils.bin2bytes(format(epaddr, "032b"))])

		return (header, new_text_lines, new_data_lines)

	@staticmethod
	def read_section(lines):
		"""
		Separate raw assembly lines to .text section lines and .data section lines.

		Parameters
		----------
		lines: str list
			raw assembly lines

		Returns
		----------
		text_lines: str list
			.text section lines

		data_lines: str list
			.data section lines
		"""

		assert lines.count(".text\n") >= 1, "assembly source must have one .text section."

		textpat = re.compile(r"\s*\.text")
		datapat = re.compile(r"\s*\.data")
		offsets = []

		for (i, line) in enumerate(lines):
			if textpat.match(line):
				offsets.append(('text', i))
			elif datapat.match(line):
				offsets.append(('data', i))

		text_lines = []
		data_lines = []
		section = "text"
		offset = 0
		for (sec, pos) in offsets:
			if (section, sec) == ("text", "data"):
				text_lines.extend(lines[offset:pos])
				section, offset = sec, pos
			elif (section, sec) == ("data", "text"):
				data_lines.extend(lines[offset:pos])
				section, offset = sec, pos

		if section == "text":
			text_lines.extend(lines[offset:])
		elif section == "data":
			data_lines.extend(lines[offset:])

		return text_lines, data_lines

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
			# ignore comment
			line = re.sub(r"#.*", "", line)
			line = line.strip()
			if line == "":
				line_num_offset -= 1
				continue

			if (".data" in line) or (".text" in line) or (".globl" in line):
				new_lines.append(line)
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

		match = re.findall(r"\s*([a-z\.]+?)\s+(.*)", line)

		if len(match) == 0:
			return (line, [])
		else:
			return (match[0][0], map(lambda s: s.strip(), match[0][1].split(",")))

	@staticmethod
	def parse_data(line):
		"""
		Parse assembly data line and emit bytecode respond to the data.

		Parameters
		----------
		line: str
			assembly line (without label)

		Returns
		----------
		bytecode: str
			bytecode respond to data
		"""
		match = re.findall(r"\s*\.long\s+(0x[0-9a-fA-F]+)", line)
		assert len(match) == 1, "wrong syntax near .long"
		return utils.bin2bytes(utils.hex2bin(match[0]))

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
			offset = target_line_num - line_num - 1
			offset_bin = utils.offset2bin(offset)
			return (None, offset_bin)
		elif operand_type == Operandtype.LABEL_ABSOLUTE:
			target_line_num = label_dict[operand]
			return (None, format(target_line_num, "026b"))

