#!/usr/bin/env python
# coding: utf-8

import sys
import struct
from bind import *

def runtest(tb, ty, omit_py = False):
	# if the test case is too large to run on Python simulator,
	# please designate `omit_py` option

	def runtest_sub(func):
		import functools

		def float2int(f):
			v = struct.pack('>f', f)
			v = struct.unpack('>I', v)[0]
			return v

		@functools.wraps(func)
		def wrapper(*args, **kwargs):
			compile(tb, quiet = True)
			if ty == "int":
				c_result = csim(tb)[0]
				if not omit_py: py_result = int(pysim(tb), 2)
			elif ty == "float":
				c_result = float2int(csim(tb)[1])
				if not omit_py: py_result = int(pysim(tb, "float"), 2)
			else:
				assert False, "type specification must be int or float"

			if omit_py:
				func(c_result)
			else:
				func(c_result, py_result)
		return wrapper
	return runtest_sub

@runtest("tests/fib", "int")
def test_fib(c, py):
	assert c == py == 233

@runtest("tests/ack", "int")
def test_ack(c, py):
	assert c == py == 29

@runtest("tests/gcd", "int")
def test_gcd(c, py):
	assert c == py == 27

@runtest("tests/abs", "int")
def test_abs(c, py):
	assert c == py == 0

@runtest("tests/fadd", "float")
def test_fadd(c, py):
	# 2.9
	assert c == py == 0x4039999a

@runtest("tests/fmul", "float")
def test_fmul(c, py):
	# 2.25
	assert c == py == 0x40100000

@runtest("tests/sin", "float")
def test_sin(c, py):
	# -1.0
	assert c == py == 0xbf800000

@runtest("tests/sqrt", "float")
def test_sqrt(c, py):
	# 1.4142135
	assert c == py == 0x3fb504f3

@runtest("tests/closure", "int")
def test_closure(c, py):
	assert c == py == 10

@runtest("tests/cls-bug", "int")
def test_cls_bug(c, py):
	assert c == py == 912

@runtest("tests/cls-bug2", "int")
def test_cls_bug2(c, py):
	assert c == py == 45

@runtest("tests/cls-rec", "int")
def test_cls_rec(c, py):
	assert c == py == 1230

@runtest("tests/spill", "int")
def test_spill(c, py):
	assert c == py == -431

@runtest("tests/spill2", "int")
def test_spill2(c, py):
	assert c == py == 77880

@runtest("tests/spill3", "int")
def test_spill3(c, py):
	assert c == py == 1617

@runtest("tests/logistic", "float")
def test_logistic(c, py):
	# 0.78293926
	assert c == py == 0x3f486eb5

@runtest("tests/mdb", "int")
def test_mdb(c, py):
	assert c == py == 676

@runtest("tests/join-reg", "int")
def test_join_reg(c, py):
	assert c == py == 912

@runtest("tests/join-reg2", "int")
def test_join_reg2(c, py):
	assert c == py == 789

@runtest("tests/join-stack", "int")
def test_join_stack(c, py):
	assert c == py == 1037

@runtest("tests/join-stack2", "int")
def test_join_stack2(c, py):
	assert c == py == 246

@runtest("tests/join-stack3", "int")
def test_join_stack3(c, py):
	assert c == py == 912

@runtest("tests/even-odd", "int")
def test_even_odd(c, py):
	assert c == py == 456

@runtest("tests/inprod", "int")
def test_inprod(c, py):
	assert c == py == 32000000

@runtest("tests/inprod-loop", "int")
def test_inprod_loop(c, py):
	assert c == py == 16826400

@runtest("tests/inprod-rec", "int")
def test_inprod_rec(c, py):
	assert c == py == 16826400

@runtest("tests/sum", "int")
def test_sum(c, py):
	assert c == py == 50005000

@runtest("tests/sum-tail", "int")
def test_sum_tail(c, py):
	assert c == py == 50005000

@runtest("tests/funcomp", "int")
def test_funcomp(c, py):
	assert c == py == 247

@runtest("tests/oscillation", "float")
def test_oscillation(c, py):
	assert c == py

@runtest("tests/flib", "int")
def test_flib(c, py):
	assert c == py == 1

if __name__ == "__main__":
	tb_name = sys.argv[1]
	print(pysim(tb_name))
