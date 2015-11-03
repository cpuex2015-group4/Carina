#!/usr/bin/env python
# coding: utf-8

import re
import utils
from parser import Parser
from parser import Operandtype

class Instruction:
	"""
	A class representing for the instance of assembly-instruction.
	"""

	@staticmethod
	def add(operands, label_dict, line_num):
		"""
		Operation : %rd <- %rs + %rt
		Format    : [ 000000 | %rs | %rt | %rd | --- | 100000 ]
		"""
		inst_bin = "000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"00000100000"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def addi(operands, label_dict, line_num):
		"""
		Operation : %rt <- %rs + $imm
		Format    : [ 001000 | %rs | %rt |    $imm    ]
		"""
		imm_pattern = re.compile(r"\$-?\d+")
		match = imm_pattern.match(operands[2])
		if match is not None:
			imm_bin = Parser.parse_operand(operands[2], Operandtype.IMMEDIATE)[1]
		else:
			# operand may be label
			imm_bin = utils.imm2bin(label_dict[operands[2]])

		assert len(imm_bin) <= 16, "too large integer operand"

		inst_bin = "001000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				imm_bin
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def and_(operands, label_dict, line_num):
		"""
		Operation : %rd <- %rs & %rt
		Format    : [ 000000 | %rd | %rs | %rt | --- | 100001 ]
		"""
		inst_bin = "000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				+ "00000100001"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def andi(operands, label_dict, line_num):
		"""
		Operation : %rt <- %rs & $imm
		Format    : [ 001100 | %rs | %rt |    $imm    ]
		"""
		inst_bin = "001100" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.IMMEDIATE)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def beq(operands, label_dict, line_num):
		"""
		Operation : if(%rs = %rt) %pc <- %pc + 1 + addr
		Format    : [ 000100 | %rs | %rt |    addr    ]
		"""
		inst_bin = "000100" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.LABEL_RELATIVE, label_dict, line_num)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def bne(operands, label_dict, line_num):
		"""
		Operation : if(%rs != %rt) %pc <- %pc + 1 + addr
		Format    : [ 000101 | %rs | %rt |    addr    ]
		"""
		inst_bin = "000101" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.LABEL_RELATIVE, label_dict, line_num)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def j(operands, label_dict, line_num):
		"""
		Operation : %pc <- addr
		Format    : [ 000010 |        addr        ]
		"""
		inst_bin = "000010" +\
				Parser.parse_operand(operands[0], Operandtype.LABEL_ABSOLUTE, label_dict)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def jal(operands, label_dict, line_num):
		"""
		Operation : %ra <- %pc + 1; %pc <- addr;
		Format    : [ 000011 |        addr        ]
		"""
		inst_bin = "000011" +\
				Parser.parse_operand(operands[0], Operandtype.LABEL_ABSOLUTE, label_dict)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def jr(operands, label_dict, line_num):
		"""
		Operation : %pc <- %rs
		Format    : [ 000000 | %rs | --- | --- | --- | 001000 ]
		"""
		inst_bin = "000000" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"000000000000000001000"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def lw(operands, label_dict, line_num):
		"""
		Operation : %rt <- Mem[%rs + $imm]
		Format    : [ 100011 | %rs | %rt |    $imm    ]
		"""
		addressing_pattern = re.compile(r"(-?\d+)?\(.*\)")
		match = addressing_pattern.match(operands[1])
		if match is not None:
			# use addressing mode
			inst_bin = "100011" +\
					Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[0] +\
					Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
					Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[1]
		else:
			# loading address value
			inst_bin = "100011" +\
					utils.reg2bin("%gp") +\
					Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
					Parser.parse_operand(operands[1], Operandtype.LABEL_RELATIVE, label_dict)[1]
		return utils.bin2bytes(inst_bin) 

	@staticmethod
	def nor(operands, label_dict, line_num):
		"""
		Operation : %rd <- ~(%rs|%rt)
		Format    : [ 000000 | %rs | %rt | %rd | --- | 100111 ]
		"""
		inst_bin = "000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"00000100111"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def or_(operands, label_dict, line_num):
		"""
		Operation : %rd <- %rs|%rt
		Format    : [ 000000 | %rs | %rt | %rd | --- | 100101 ]
		"""
		inst_bin = "000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"00000100101"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def ori(operands, label_dict, line_num):
		"""
		Operation : %rt <- %rs | $imm
		Format    : [ 001101 | %rs | %rt |    $imm    ]
		"""
		inst_bin = "001101" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.IMMEDIATE)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def slt(operands, label_dict, line_num):
		"""
		Operation : %rd <- (%rs < %rt) ? 1 : 0
		Format    : [ 000000 | %rs | %rt | %rd | --- | 101010 ]
		"""
		inst_bin = "000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"00000101010"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def slti(operands, label_dict, line_num):
		"""
		Operation : %rt <- (%rs < $imm) ? 1 : 0
		Format    : [ 001010 | %rs | %rt |    $imm    ]
		"""
		inst_bin = "001010" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.IMMEDIATE)[1]
		return utils.bin2bytes(inst_bin)

	#####according to henepata, R[rd] = R[rs] << shamt
	###but to web assembler, R[rd] = R[rt] << shamt
	@staticmethod
	def sll(operands, label_dict, line_num):
		"""
		Operation : %rd <- %rt << shamt
		Format    : [ 000000 | --- | %rt | %rd | shamt | 000000 ]
		"""
		inst_bin = "00000000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.SHAMT)[1] +\
				"000000"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def srl(operands, label_dict, line_num):
		"""
		Operation : %rd <- %rs >> shamt
		Format    : [ 000000 | %rs | --- | %rd | shamt | 000010 ]
		"""
		opecode_bin = format(int("0", 16), "06b")
		funct_bin = format(int("02", 16), "06b")
		inst_bin = "000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				"00000" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.SHAMT)[1] +\
				"000010"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def sw(operands, label_dict, line_num):
		"""
		Operation : Mem[%rs + $imm] <- %rt
		Format    : [ 101011 | %rs | %rt |    $imm    ]
		"""
		inst_bin = "101011" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def sub(operands, label_dict, line_num):
		"""
		Operation : %rd <- %rs - %rt
		Format    : [ 000000 | %rs | %rt | %rd | --- | 100010 ]
		"""
		inst_bin = "000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"00000100010"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def move(operands, label_dict, line_num):
		"""
		(Syntax Sugar)
		"""
		return Instruction.add([operands[0], "%zero", operands[1]], label_dict, line_num) 

	@staticmethod
	def subi(operands, label_dict, line_num):
		"""
		(Syntax Sugar)
		"""
		def imm_inverse(imm):
			return imm.replace("$", "$-")
		return Instruction.addi([operands[0], operands[1], imm_inverse(operands[2])], label_dict, line_num)

	@staticmethod
	def li(operands, label_dict, line_num):
		"""
		(Syntax Sugar)
		"""
		return Instruction.addi([operands[0], "%zero", operands[1]], label_dict, line_num)

	@staticmethod
	def hlt(operands, label_dict, line_num):
		inst_bin = "11111111111111111111111111111111"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def bclt(operands, label_dict, line_num):
		"""
		Operation : if(FPCond) %pc <- %pc + 1 + $addr;
		Format : [ 010001 | 01000 | 00001 | $addr ]
		"""
		inst_bin = "0100010100000001" +\
				Parser.parse_operand(operands[0], Operandtype.LABEL_RELATIVE, label_dict, line_num)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def bclf(operands, label_dict, line_num):
		"""
		Operation : if(!FPCond) %pc <- %pc + 1 + $addr;
		Format : [ 010001 | 01000 | 00000 | $addr ]
		"""
		inst_bin = "0100010100000000" +\
				Parser.parse_operand(operands[0], Operandtype.LABEL_RELATIVE, label_dict, line_num)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def mult(operands, label_dict, line_num):
		"""
		Operation : %rd <- %rs * %rt
		Format    : [ 000000 | %rs | %rt | %rd | --- | 011000 ]
		"""
		inst_bin = "000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"00000011000"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def div(operands, label_dict, line_num):
		"""
		Operation : %rd <- %rs / %rt
		Format    : [ 000000 | %rs | %rt | %rd | --- | 010010 ]
		"""
		inst_bin = "000000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"00000011010"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def fadd(operands, label_dict, line_num):
		"""
		Operation : %fd <- %fs +. %ft
		Format : [ 010001 | 10000 | %ft | %fs | %fd | 000000 ]
		"""
		inst_bin = "01000110000" +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"000000"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def fmul(operands, label_dict, line_num):
		"""
		Operation : %fd <- %fs *. %ft
		Format : [ 010001 | 10000 | %ft | %fs | %fd | 000010 ]
		"""
		inst_bin = "01000110000" +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"000010"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def finv(operands, label_dict, line_num):
		"""
		Operation : %fd <- 1 /. %ft
		Format : [ 010001 | 10000 | %ft | --- | %fd | 000011 ]
		"""
		inst_bin = "01000110000" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				"00000" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"000011"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def fsub(operands, label_dict, line_num):
		"""
		Operation : %fd <- %fs -. %ft
		Format : [ 010001 | 10000 | %ft | %fs | %fd | 000001 ]
		"""
		inst_bin = "01000110000" +\
				Parser.parse_operand(operands[2], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"000001"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def flw(operands, label_dict, line_num):
		"""
		Operation : %ft <- Mem[%rs + $imm]
		Format    : [ 110001 | %rs | %ft |    $imm    ]
		"""
		addressing_pattern = re.compile(r"(-?\d+)?\(.*\)")
		match = addressing_pattern.match(operands[1])
		if match is not None:
			# use addressing mode
			inst_bin = "110001" +\
					Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[0] +\
					Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
					Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[1]
		else:
			# loading address value
			inst_bin = "110001" +\
					utils.reg2bin("%gp") +\
					Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
					Parser.parse_operand(operands[1], Operandtype.LABEL_RELATIVE, label_dict)[1]
		return utils.bin2bytes(inst_bin) 

	@staticmethod
	def fsw(operands, label_dict, line_num):
		"""
		Operation : Mem[%rs + $imm] <- %ft
		Format    : [ 111001 | %rs | %ft |    $imm    ]
		"""
		inst_bin = "111001" +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT)[0] +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_INDIRECT, label_dict)[1]
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def feq(operands, label_dict, line_num):
		"""
		Operation : FPcond = (%fs == %ft) ? 1 : 0
		Format : [ 010001 | 10000 | %ft | %fs | --- | 110010 ]
		"""
		inst_bin = "01000110000" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				"00000110010"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def flt(operands, label_dict, line_num):
		"""
		Operation : FPcond = (%fs < %ft) ? 1 : 0
		Format : [ 010001 | 10000 | %ft | %fs | --- | 111100 ]
		"""
		inst_bin = "01000110000" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				"00000111100"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def fle(operands, label_dict, line_num):
		"""
		Operation : FPcond = (%fs <= %ft) ? 1 : 0
		Format : [ 010001 | 10000 | %ft | %fs | --- | 111110 ]
		"""
		inst_bin = "01000110000" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				Parser.parse_operand(operands[1], Operandtype.REGISTER_DIRECT)[0] +\
				"00000111110"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def fmove(operands, label_dict, line_num):
		"""
		(Syntax Sugar)
		"""
		return Instruction.fadd([operands[0], "%f0", operands[1]], label_dict, line_num) 

	@staticmethod
	def in_(operands, label_dict, line_num):
		"""
		Operation : RS232C receiver
		Format : [ 011010 | ----- | %rt | -----(16bit) ]
		"""
		inst_bin = "01101000000" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"0000000000000000"
		return utils.bin2bytes(inst_bin)

	@staticmethod
	def out(operands, label_dict, line_num):
		"""
		Operation : RS232C receiver
		Format : [ 011011 | 00000 | %rt | -----(16bit) ]
		"""
		inst_bin = "01101100000" +\
				Parser.parse_operand(operands[0], Operandtype.REGISTER_DIRECT)[0] +\
				"0000000000000000"
		return utils.bin2bytes(inst_bin)
