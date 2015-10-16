#!/usr/bin/env python
# coding: utf-8

import pprint

#if minus, disolute it
def bin2int(binary):
	def turn_binary(binary):
		if len(binary) == 0:
			return ""
		elif binary[0] == "0":
			return "1" + turn_binary(binary[1:])
		elif binary[0] == "1":
			return "0" + turn_binary(binary[1:])
	if binary[0] == "1":
		return -(int(turn_binary(binary[1:]), 2) + 1)
	else:
		return int(binary, 2)

def and_bin(bin1, bin2):
	ans_bin = ""
	for i, bit1 in enumerate(bin1):
		bit2 = bin2[i]
		and_bin += str(int(bit1) * int(bit2))
	return ans_bin

def or_bin(bin1, bin2):
	ans_bin = ""
	for i, bit1 in enumerate(bin1):
		bit2 = bin2[i]
		and_bin += str(int(bit1) + int(bit2))
		if ans_bin == 2:
			ans_bin += 1
	return ans_bin

def nor_bin(bin1, bin2):
	ans_bin = ""
	for i, bit1 in enumerate(bin1):
		bit2 = bin2[i]
		and_bin += str((int(bit1) - 1) * (int(bit2) - 1))
	return ans_bin

def left_shift_logical(binary, shamt):
	zero_shamt  = ""
	for i in range(shamt):
		zero_shamt += "0"
	return binary[shamt:] +  zero_shamt

def right_shift_logical(binary, shamt):
	zero_shamt  = ""
	for i in range(shamt):
		zero_shamt += "0"
	return zero_shamt + binary[0:-shamt] 

class Simulator:
	data_size = 0
	text_size = 0
	text_offset = 0
	pc = 0
	reg = {}
	inst_mem = []
	mem = {}

#init register and memories
	@staticmethod
	def initialization():
		for i in range(32):
			Simulator.reg[format(i, "05b")] = format(0, "032b")
#stack pointer 
		Simulator.reg["11101"] = format(100, "032b")
		print("Simulator.text_offset = " + str(Simulator.text_offset))
		Simulator.pc = Simulator.text_offset / 4
		print(Simulator.reg)

#read first 16byte
#magic number
#data size
#text size
#text offset
	@staticmethod
	def load_header(binary):
		four_byte_hex = ""
		for i in range(4):
			a_byte = binary[4 + i]
			one_byte_hex = format(ord(a_byte), '02x')
			four_byte_hex = one_byte_hex
		Simulator.data_size = int(four_byte_hex, 16)
		four_byte_hex = ""
		for i in range(4):
			a_byte = binary[8 + i]
			one_byte_hex = format(ord(a_byte), '02x')
			four_byte_hex = one_byte_hex
		Simulator.text_size = int(four_byte_hex, 16)
		for i in range(4):
			a_byte = binary[12 + i]
			one_byte_hex = format(ord(a_byte), '02x')
			four_byte_hex = one_byte_hex
		Simulator.text_offset = int(four_byte_hex, 16)

#read instructions and load them to the memorys(list)
#a memory has 32bit(hex is stored)
	@staticmethod
	def load_instruction(text):
		i = 0
		binary = [text][0]
		Simulator.load_header(binary)
		i += 16
		while(i < len(binary)):
			four_byte_hex = ""
			for j in range(0,4):
				a_byte = binary[i + j]
				one_byte_hex = format(ord(a_byte), '02x')
				four_byte_hex += one_byte_hex
			Simulator.inst_mem.append(four_byte_hex)
			i += 4

	@staticmethod
	def fecth_instruction(inst):
		print("PC = " + str(Simulator.pc))
		inst_bin = format(int(inst, 16), '032b')
		operation_bin = inst_bin[0:6]
		funct_bin = inst_bin[26:]
		if(operation_bin == "000000" and funct_bin == "100000"):
			#print("add")
			return Simulator.add(inst_bin)
		elif(operation_bin == "001000"):
			#print("addi")
			return Simulator.addi(inst_bin)
		elif(operation_bin == "000000" and funct_bin == "100100"):
			#print("and_")
			return Simulator.and_(inst_bin)
		elif(operation_bin == "000100"):
			#print("beq")
			return Simulator.beq(inst_bin)
		elif(operation_bin == "000101"):
			#print("bne")
			return Simulator.bne(inst_bin)
		elif(operation_bin == "000010"):
			#print("j")
			return Simulator.j(inst_bin)
		elif(operation_bin == "000011"):
			#print("jal")
			return Simulator.jal(inst_bin)
		elif(operation_bin == "000000" and funct_bin == "001000"):
			#print("jr")
			return Simulator.jr(inst_bin)
		elif(operation_bin == "100011"):
			#print("lw")
			return Simulator.lw(inst_bin)
		elif(operation_bin == "000000" and funct_bin == "100111"):
			#print("nor")
			return Simulator.nor(inst_bin)
		elif(operation_bin == "000000" and funct_bin == "100101"):
			#print("or_")
			return Simulator.or_(inst_bin)
		elif(operation_bin == "001101"):
			#print("nst_bin")
			return Simulator.ori(inst_bin)
		elif(operation_bin == "000000" and funct_bin == "101010"):
			#print("slt")
			return Simulator.slt(inst_bin)
		elif(operation_bin == "001010"):
			#print("slti")
			return Simulator.slti(inst_bin)
		elif(operation_bin == "000000" and funct_bin == "000000"):
			#print("sll")
			return Simulator.sll(inst_bin)
		elif(operation_bin == "000000" and funct_bin == "000010"):
			#print("srl")
			return Simulator.srl(inst_bin)
		elif(operation_bin == "101011"):
			#print("sw")
			return Simulator.sw(inst_bin)
		elif(operation_bin == "000000" and funct_bin == "100010"):
			#print("sub")
			return Simulator.sub(inst_bin)
		elif(operation_bin == "111111" and funct_bin == "111111"):
			#print("hlt")
			return Simulator.hlt(inst_bin)
		else:
			print("Not Found"),
			print(inst_bin)

	@staticmethod
	def add(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		reg_d_bin = inst_bin[16:21]
		Simulator.reg[reg_d_bin] = format(bin2int(Simulator.reg[reg_s_bin]) + bin2int(Simulator.reg[reg_t_bin]), "032b")
		Simulator.pc += 1
		return 1

	@staticmethod
	def addi(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		imm_bin = inst_bin[16:]
		Simulator.reg[reg_t_bin] = format(bin2int(Simulator.reg[reg_s_bin]) + bin2int(imm_bin), "032b")
		Simulator.pc += 1
		return 1

	@staticmethod
	def and_(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		reg_d_bin = inst_bin[16:21]
		Simulator.reg[reg_d_bin] = and_bin(Simulator.reg[reg_s_bin], Simulator.reg[reg_t_bin])
		Simulator.pc += 1
		return 1

	@staticmethod
	def beq(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		imm_bin = inst_bin[16:]
		#print(Simulator.reg[reg_s_bin])
		#print(Simulator.reg[reg_t_bin])
		if Simulator.reg[reg_s_bin] == Simulator.reg[reg_t_bin]:
			Simulator.pc += bin2int(imm_bin)
		else:
			Simulator.pc += 1
		return 1

	@staticmethod
	def bne(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		imm_bin = inst_bin[16:]
		#print(Simulator.reg[reg_s_bin])
		#print(Simulator.reg[reg_t_bin])
		if Simulator.reg[reg_s_bin] != Simulator.reg[reg_t_bin]:
			#print("offset : " + str(int(imm_bin, 2)))
			Simulator.pc += bin2int(imm_bin)
		else:
			Simulator.pc += 1
		return 1

	@staticmethod
	def j(inst_bin):
		imm_bin = inst_bin[6:]
		Simulator.pc = bin2int(Simulator.reg[imm_bin]) / 4
		return 1

	@staticmethod
	def jal(inst_bin):
		Simulator.reg["11111"] = format((Simulator.pc + 1) * 4, "032b")
		imm_bin = inst_bin[6:]
		Simulator.pc = bin2int(imm_bin) / 4
		return 1

	@staticmethod
	def jr(inst_bin):
		reg_s_bin = inst_bin[6:11]
		address_bin = Simulator.reg[reg_s_bin]
		Simulator.pc = bin2int(address_bin) / 4
		return 1

	@staticmethod
	def lw(inst_bin):
		#print(format(int(inst_bin, 2), "08x"))
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		imm_bin = inst_bin[16:]
		try:
			#print(format(4 * (bin2int(Simulator.reg[reg_s_bin]) + bin2int(imm_bin)), "032b"))
			Simulator.reg[reg_t_bin] = Simulator.mem[format(4 * (bin2int(Simulator.reg[reg_s_bin]) + bin2int(imm_bin)), "032b")]
		except Exception:
			#pprint.pprint(Simulator.reg)
			#pprint.pprint(Simulator.mem)
			raise Exception
		Simulator.pc += 1
		return 1

	@staticmethod
	def nor(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		reg_d_bin = inst_bin[16:21]
		Simulator.reg[reg_d_bin] = nor_bin(Simulator.reg[reg_s_bin], Simulator.reg[reg_t_bin])
		Simulator.pc += 1
		return 1

	@staticmethod
	def or_(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		reg_d_bin = inst_bin[16:21]
		Simulator.reg[reg_d_bin] = or_bin(Simulator.reg[reg_s_bin], Simulator.reg[reg_t_bin])
		Simulator.pc += 1
		return 1

	@staticmethod
	def ori(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		imm_bin = inst_bin[16:]
		Simulator.reg[reg_t_bin] = or_bin("0000000000000000" + imm_bin, Simulator.reg[reg_s_bin])
		Simulator.pc += 1
		return 1

	@staticmethod
	def slt(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		reg_d_bin = inst_bin[16:21]
		if bin2int(Simulator.reg[reg_s_bin]) < bin2int(Simulator.reg[reg_t_bin]):
			Simulator.reg[reg_d_bin] = format(1, "032b")
		else:
			Simulator.reg[reg_d_bin] = format(0, "032b")
		Simulator.pc += 1
		return 1

	@staticmethod
	def slti(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		imm_bin = inst_bin[16:]
		#print(Simulator.reg[reg_s_bin])
		#print(imm_bin)
		if bin2int(Simulator.reg[reg_s_bin]) < bin2int(imm_bin):
			#print(True)
			Simulator.reg[reg_t_bin] = format(1, "032b")
		else:
			#print(False)
			Simulator.reg[reg_t_bin] = format(0, "032b")
		Simulator.pc += 1
		return 1

	@staticmethod
	def sll(inst_bin):
		#reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		reg_d_bin = inst_bin[16:21]
		shamt_bin = inst_bin[21:26]
		Simulator.reg[reg_d_bin] = left_shift_logical(Simulator.reg[reg_t_bin], int(shamt_bin, 2))
		Simulator.pc += 1
		return 1

	@staticmethod
	def srl(inst_bin):
		reg_t_bin = inst_bin[11:16]
		reg_d_bin = inst_bin[16:21]
		shamt_bin = inst_bin[21:26]
		Simulator.reg[reg_d_bin] = left_right_logical(Simulator.reg[reg_t_bin], int(shamt_bin, 2))
		Simulator.pc += 1
		return 1

	@staticmethod
	def sw(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		imm_bin = inst_bin[16:]
		Simulator.mem[format(4 * (bin2int(Simulator.reg[reg_s_bin]) + bin2int(imm_bin)), "032b")] = Simulator.reg[reg_t_bin]
		#print(format(4 * (bin2int(Simulator.reg[reg_s_bin]) + bin2int(imm_bin)), "032b"))
		#pprint.pprint(Simulator.reg)
		#pprint.pprint(Simulator.mem)
		Simulator.pc += 1
		return 1

	@staticmethod
	def sub(inst_bin):
		reg_s_bin = inst_bin[6:11]
		reg_t_bin = inst_bin[11:16]
		reg_d_bin = inst_bin[16:21]
		Simulator.reg[reg_d_bin] = format(bin2int(Simulator.reg[reg_s_bin]) - bin2int(Simulator.reg[reg_t_bin]), "032b")
		Simulator.pc += 1
		return 1

	@staticmethod
	def hlt(inst_bin):
		pprint.pprint(Simulator.reg)
		pprint.pprint(Simulator.mem)
		return 0
