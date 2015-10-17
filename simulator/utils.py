#!/usr/bin/env python
# coding: utf-8

#if minus, dissolve it
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

def word2int(bytecodes):
	"""
	Convert 32bit bytecodes to integer value.
	
	Parameters
	----------
	bytecodes: str
		the original bytecodes
	
	Returns
	----------
	int_val: int
		converted integer value
	"""
	return sum([ord(bytecodes[i])*(0x100**(3-i)) for i in range(4)])

def word2hex(bytecodes):
	"""
	Convert 32bit bytecodes to hex encoded integer value.
	
	Parameters
	----------
	bytecodes: str
		the original bytecodes
	
	Returns
	----------
	hex: str
		hex encoded integer value
	"""
	return format(word2int(bytecodes), "08x")

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

