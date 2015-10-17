#!/usr/bin/env python
# coding: utf-8

import pprint
import utils

class Simulator:
	"""
	A class representing for Carina ISA simulator.
	"""

	def __init__(self, filename):
		"""
		Parameters
		----------
		filename: str
			the name of file which is to be simulated
		"""
		self.data_size = 0
		self.text_size = 0
		self.entry_point = 0
		self.pc = 0
		self.reg = {}
		self.inst_mem = []
		self.mem = {}

		with open(filename, "rb") as file_in:
			self.binary = file_in.read()
			self.load_header()
			self.load_instruction()

		for i in range(32):
			# init registers
			self.reg[format(i, "05b")] = "0"*32 

		# stack pointer 
		self.reg["11101"] = format(100, "032b")
		self.pc = self.entry_point / 4

	
	def simulate(self):
		"""
		Execute simulation until hlt instruction. The target file is given in __init__.

		Returns
		----------
		rv: int
			the content of return value register %v0
		"""
		while(True):
			inst = self.inst_mem[self.pc]
			res = self.fetch_instruction(inst)
			# halting at `hlt` instruction
			if(res == 0): break
	
		# return the content of %v0
		return int(self.reg["00010"], 2)

	def load_header(self):
		"""
		Read the first 16 bytes of the target file as the header.
		The header format is
		[ "CARN" | .data size (4B) | .text size (4B) | entry point (4B) ]
		"""

		assert self.binary[0:4] == "CARN", "the target file must have a valid magic number at the head."

		self.data_size   = utils.word2int(self.binary[4:8])
		self.text_size   = utils.word2int(self.binary[8:12])
		self.entry_point = utils.word2int(self.binary[12:16])

	def load_instruction(self):
		"""
		Read instructions from the target binary and load them to the memory.
		Each single memory cell can be stored 32bit data.
		"""
		for i in range(16, len(self.binary), 4):
			# convert each word to hex encoded value
			inst = utils.word2hex(self.binary[i:i+4])
			self.inst_mem.append(inst)

	def fetch_instruction(self, inst):
		inst_bin = format(int(inst, 16), '032b')
		operation_bin = inst_bin[0:6]
		funct_bin = inst_bin[26:]
		if(operation_bin == "000000" and funct_bin == "100000"):
			return Simulator.add(self, inst_bin)
		elif(operation_bin == "001000"):
			return Simulator.addi(self, inst_bin)
		elif(operation_bin == "000000" and funct_bin == "100100"):
			return Simulator.and_(self, inst_bin)
		elif(operation_bin == "000100"):
			return Simulator.beq(self, inst_bin)
		elif(operation_bin == "000101"):
			return Simulator.bne(self, inst_bin)
		elif(operation_bin == "000010"):
			return Simulator.j(self, inst_bin)
		elif(operation_bin == "000011"):
			return Simulator.jal(self, inst_bin)
		elif(operation_bin == "000000" and funct_bin == "001000"):
			return Simulator.jr(self, inst_bin)
		elif(operation_bin == "100011"):
			return Simulator.lw(self, inst_bin)
		elif(operation_bin == "000000" and funct_bin == "100111"):
			return Simulator.nor(self, inst_bin)
		elif(operation_bin == "000000" and funct_bin == "100101"):
			return Simulator.or_(self, inst_bin)
		elif(operation_bin == "001101"):
			return Simulator.ori(self, inst_bin)
		elif(operation_bin == "000000" and funct_bin == "101010"):
			return Simulator.slt(self, inst_bin)
		elif(operation_bin == "001010"):
			return Simulator.slti(self, inst_bin)
		elif(operation_bin == "000000" and funct_bin == "000000"):
			return Simulator.sll(self, inst_bin)
		elif(operation_bin == "000000" and funct_bin == "000010"):
			return Simulator.srl(self, inst_bin)
		elif(operation_bin == "101011"):
			return Simulator.sw(self, inst_bin)
		elif(operation_bin == "000000" and funct_bin == "100010"):
			return Simulator.sub(self, inst_bin)
		elif(operation_bin == "111111" and funct_bin == "111111"):
			return Simulator.hlt(self, inst_bin)
		else:
			raise ValueError("no match with any instruction for bytecode `{}`".format(inst_bin))

	@staticmethod
	def decode_R(inst_bin):
		return inst_bin[6:11], inst_bin[11:16], inst_bin[16:21], inst_bin[21:26]

	@staticmethod
	def decode_I(inst_bin):
		return inst_bin[6:11], inst_bin[11:16], inst_bin[16:]

	@classmethod
	def add(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, reg_d_bin, _ = cls.decode_R(inst_bin)
		sim.reg[reg_d_bin] = format(utils.bin2int(sim.reg[reg_s_bin]) + utils.bin2int(sim.reg[reg_t_bin]), "032b")
		sim.pc += 1
		return 1

	@classmethod
	def addi(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, imm_bin = cls.decode_I(inst_bin)
		sim.reg[reg_t_bin] = format(utils.bin2int(sim.reg[reg_s_bin]) + utils.bin2int(imm_bin), "032b")
		sim.pc += 1
		return 1

	@classmethod
	def and_(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, reg_d_bin, _ = cls.decode_R(inst_bin)
		sim.reg[reg_d_bin] = and_bin(sim.reg[reg_s_bin], sim.reg[reg_t_bin])
		sim.pc += 1
		return 1

	@classmethod
	def beq(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, imm_bin = cls.decode_I(inst_bin)
		if sim.reg[reg_s_bin] == sim.reg[reg_t_bin]:
			sim.pc += utils.bin2int(imm_bin)
		else:
			sim.pc += 1
		return 1

	@classmethod
	def bne(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, imm_bin = cls.decode_I(inst_bin)
		if sim.reg[reg_s_bin] != sim.reg[reg_t_bin]:
			sim.pc += utils.bin2int(imm_bin)
		else:
			sim.pc += 1
		return 1

	@staticmethod
	def j(sim, inst_bin):
		imm_bin = inst_bin[6:]
		sim.pc = utils.bin2int(imm_bin) / 4
		return 1

	@staticmethod
	def jal(sim, inst_bin):
		sim.reg["11111"] = format((sim.pc + 1) * 4, "032b")
		imm_bin = inst_bin[6:]
		sim.pc = utils.bin2int(imm_bin) / 4
		return 1

	@staticmethod
	def jr(sim, inst_bin):
		reg_s_bin = inst_bin[6:11]
		address_bin = sim.reg[reg_s_bin]
		sim.pc = utils.bin2int(address_bin) / 4
		return 1

	@classmethod
	def lw(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, imm_bin = cls.decode_I(inst_bin)
		try:
			sim.reg[reg_t_bin] = sim.mem[format(4 * (utils.bin2int(sim.reg[reg_s_bin]) + utils.bin2int(imm_bin)), "032b")]
		except Exception as ex:
			raise ex
		sim.pc += 1
		return 1

	@classmethod
	def nor(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, reg_d_bin, _ = cls.decode_R(inst_bin)
		sim.reg[reg_d_bin] = utils.nor_bin(sim.reg[reg_s_bin], sim.reg[reg_t_bin])
		sim.pc += 1
		return 1

	@classmethod
	def or_(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, reg_d_bin, _ = cls.decode_R(inst_bin)
		sim.reg[reg_d_bin] = utils.or_bin(sim.reg[reg_s_bin], sim.reg[reg_t_bin])
		sim.pc += 1
		return 1

	@classmethod
	def ori(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, imm_bin = cls.decode_I(inst_bin)
		sim.reg[reg_t_bin] = utils.or_bin("0000000000000000" + imm_bin, sim.reg[reg_s_bin])
		sim.pc += 1
		return 1

	@classmethod
	def slt(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, reg_d_bin, _ = cls.decode_R(inst_bin)
		if utils.bin2int(sim.reg[reg_s_bin]) < utils.bin2int(sim.reg[reg_t_bin]):
			sim.reg[reg_d_bin] = format(1, "032b")
		else:
			sim.reg[reg_d_bin] = format(0, "032b")
		sim.pc += 1
		return 1

	@classmethod
	def slti(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, imm_bin = cls.decode_I(inst_bin)
		if utils.bin2int(sim.reg[reg_s_bin]) < utils.bin2int(imm_bin):
			sim.reg[reg_t_bin] = format(1, "032b")
		else:
			sim.reg[reg_t_bin] = format(0, "032b")
		sim.pc += 1
		return 1

	@classmethod
	def sll(cls, sim, inst_bin):
		_, reg_t_bin, reg_d_bin, shamt_bin = cls.decode_R(inst_bin)
		sim.reg[reg_d_bin] = utils.left_shift_logical(sim.reg[reg_t_bin], int(shamt_bin, 2))
		sim.pc += 1
		return 1

	@classmethod
	def srl(cls, sim, inst_bin):
		_, reg_t_bin, reg_d_bin, shamt_bin = cls.decode_R(inst_bin)
		sim.reg[reg_d_bin] = utils.left_right_logical(sim.reg[reg_t_bin], int(shamt_bin, 2))
		sim.pc += 1
		return 1

	@classmethod
	def sw(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, imm_bin = cls.decode_I(inst_bin)
		sim.mem[format(4 * (utils.bin2int(sim.reg[reg_s_bin]) + utils.bin2int(imm_bin)), "032b")] = sim.reg[reg_t_bin]
		sim.pc += 1
		return 1

	@classmethod
	def sub(cls, sim, inst_bin):
		reg_s_bin, reg_t_bin, reg_d_bin, _ = cls.decode_R(inst_bin)
		sim.reg[reg_d_bin] = format(utils.bin2int(sim.reg[reg_s_bin]) - utils.bin2int(sim.reg[reg_t_bin]), "032b")
		sim.pc += 1
		return 1

	@staticmethod
	def hlt(sim, inst_bin):
		print("HALT\n{}".format("=" * 20))
		pprint.pprint(sim.reg)
		pprint.pprint(sim.mem)
		return 0
