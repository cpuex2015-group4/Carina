#!/usr/bin/env python
# coding: utf-8

"""
This module includes utility methods for binary operation/conversion.
"""

REG_DICT = {"%zero" : 0, "%at" : 1,\
		"%v0" : 2, "%v1" : 3,\
		"%a0" : 4, "%a1" : 5, "%a2" : 6, "%a3" : 7,\
		"%t0" : 8, "%t1" : 9, "%t2" : 10, "%t3" : 11, "%t4" : 12, "%t5" : 13, "%t6" : 14, "%t7" : 15,\
		"%s0" : 16, "%s1" : 17, "%s2" : 18, "%s3" : 19, "%s4" : 20, "%s5" : 21, "%s6" : 22, "%s7" : 23,\
		"%t8" : 24, "%t9" : 25,\
		"%k0" : 26, "%k1" : 27,\
		"%gp" : 28, "%sp" : 29, "%fp" : 30, "%ra" : 31}

def binary_inc(binary):
	i = len(binary)
	lst = list(binary)
	while(True):
		if lst[i - 1] == "0":
			lst[i - 1] = "1"
			break
		else:
			lst[i - 1] = "0"
			i -= 1
	return "".join(lst)

def dissolve_minus(binary):
	new_binary = ""
	binary = binary.replace("-", "")
	while(len(binary) > 0):
		if binary[0] == '1':
			new_binary += '0'
		else:
			new_binary += '1'
		binary = binary[1:]
	return binary_inc(new_binary)

def bin2hex(binary):
	hex_len = len(binary) / 4
	return format(int(binary, 2), '0' + str(hex_len) + 'x')

def hex2bin(hex):
	return format(int(hex, 16), "032b")

def imm2bin(immediate):
	if immediate < 0:
		binary = format(immediate, '017b')
		binary = dissolve_minus(binary)
	else:
		binary = format(immediate, '016b')
	return binary 

def shamt2bin(shamt):
	if shamt < 0:
		binary = format(shamt, '06b')
		binary = dissolve_minus(binary)
	else:
		binary = format(shamt, '05b')
	return binary 

def address2bin(address):
	if address < 0:
		binary = format(address, '027b')
		binary = dissolve_minus(binary)
	else:
		binary = format(address, '026b')
	return binary

def offset2bin(offset):
	if offset < 0:
		binary = format(offset, '017b')
		binary = dissolve_minus(binary)
	else:
		binary = format(offset, '016b')
	return binary

def reg2bin(register):
	"""
	Return register code

	Parameters
	----------
	register: str
		register name
	
	Returns
	----------
	regcode: str
		register code
	"""
	reg_num = REG_DICT[register]
	binary = format(reg_num, '05b')
	return binary

def bin2bytes(binary):
	"""
	Convert (binary encoded) integer value to bytecode (big-endian). 

	Parameters
	----------
	binary: str
		binary encoded integer value

	Returns
	----------
	bytecode: bytes
		ascii encoded bytecode
	"""
	assert len(binary) == 32
	byte1 = chr(int(binary[0:8], 2))
	byte2 = chr(int(binary[8:16], 2))
	byte3 = chr(int(binary[16:24], 2))
	byte4 = chr(int(binary[24:32], 2))
	return (byte1 + byte2 + byte3 + byte4)
