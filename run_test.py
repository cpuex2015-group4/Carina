#!/usr/bin/env python
# coding: utf-8

import sys, os
import struct
import subprocess
from assembler.assembler import Assembler
from simulator.python.simulator import Simulator

ROOT = os.path.dirname(os.path.abspath(__file__))
MIN_CAML = os.path.join(ROOT, "min-caml/min-caml")
CSIM = os.path.join(ROOT, "simulator/c/csim")

def compile(name):
	subprocess.call([MIN_CAML, name])
	os.system("cat min-caml/libmincaml.S >> {}.s".format(name))
	asmblr = Assembler()
	asmblr.assemble(name + ".s")

def csim(name):
	# execute on c simulator
	p = subprocess.Popen([CSIM, "-f" + name + ".o"],
			stdin  = subprocess.PIPE,
			stdout = subprocess.PIPE,
			stderr = subprocess.PIPE,
			shell = False)
	# capture output in stdout as return value
	# output := int:[int_return],float:[float_return]
	rvs = p.stderr.readlines()[1].split(",") #["int"+Vi, "float"+Vf]
	rvi = rvs[0].replace("int:", "")
	rvf = rvs[1].replace("float:", "")
	return (int(rvi), float(rvf))

def pysim(name, t = "int"):
	# execute on python simulator
	sim = Simulator(name + ".o")
	d = {"int": 0, "float": 1}
	return sim.simulate()[d[t]]

def runtest(tb, ty):
	def runtest_sub(func):
		import functools

		def float2int(f):
			v = struct.pack('>f', f)
			v = struct.unpack('>I', v)[0]
			return v

		@functools.wraps(func)
		def wrapper(*args, **kwargs):
			compile(tb)
			if ty == "int":
				c_result = csim(tb)[0]
				py_result = int(pysim(tb), 2)
			elif ty == "float":
				c_result = float2int(csim(tb)[1])
				py_result = int(pysim(tb, "float"), 2)
			else:
				assert False, "type specification must be int or float"
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
	# assert c  == 0x4039999a
	assert py == 0x4039999a

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
	# assert c  == 0x3fb504f3
	assert py == 0x3fb504f3

@runtest("tests/closure", "int")
def test_closure(c, py):
	assert c == py == 10

@runtest("tests/cls-bug", "int")
def test_cls_bug(c, py):
	assert c == py == 912

@runtest("tests/cls-bug2", "int")
def test_cls_bug2(c, py):
	assert c == py == 45

@runtest("tests/spill", "int")
def test_spill(c, py):
	assert c == py == -431

@runtest("tests/spill3", "int")
def test_spill3(c, py):
	assert c == py == 1617

if __name__ == "__main__":
	tb_name = sys.argv[1]
	print(pysim(tb_name))
