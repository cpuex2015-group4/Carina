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
		"%gp" : 28, "%sp" : 29, "%fp" : 30, "%ra" : 31,
		"%f0" : 0, "%f1" : 1, "%f2" : 2, "%f3" : 3, "%f4" : 4, "%f5" : 5, "%f6" : 6, "%f7" : 7, 
		"%f8" : 8, "%f9" : 9, "%f10" : 10, "%f11" : 11, "%f12" : 12, "%f13" : 13, "%f14" : 14, "%f15" : 15, 
		"%f16" : 16, "%f17" : 17, "%f18" : 18, "%f19" : 19, "%f20" : 20, "%f21" : 21, "%f22" : 22, "%f23" : 23, 
		"%f24" : 24, "%f25" : 25, "%f26" : 26, "%f27" : 27, "%f28" : 28, "%f29" : 29, "%f30" : 30, "%f31" : 31 }

def bin2hex(binary):
	hex_len = len(binary) / 4
	return format(int(binary, 2), '0' + str(hex_len) + 'x')

def hex2bin(hex):
	return format(int(hex, 16), "032b")

def imm2bin(immediate):
	assert abs(immediate) < 2**15, "too large immediate"
	if immediate < 0:
		return format(2**16+immediate, "016b")
	else:
		return format(immediate, "016b")

def shamt2bin(shamt):
	assert shamt >= 0, "shamt must be positive value"
	assert shamt < 2**5, "shamt must be in the range of 0 <= shamt <= 31"
	return format(shamt, '05b')

def address2bin(address):
	assert abs(address) < 2**25, "too large offset"
	if offset < 0:
		return format(2**26+offset, "026b")
	else:
		return format(offset, "026b")

def offset2bin(offset):
	assert abs(offset) < 2**15, "too large offset"
	if offset < 0:
		return format(2**16+offset, "016b")
	else:
		return format(offset, "016b")

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
