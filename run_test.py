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
	p = subprocess.Popen([CSIM, name + ".o"],
			stdin  = subprocess.PIPE,
			stdout = subprocess.PIPE,
			stderr = subprocess.PIPE,
			shell = False)
	# capture output in stdout as return value
	rv = p.stdout.readlines()[0]
	return int(rv)

def pysim(name, t = "int"):
	# execute on python simulator
	sim = Simulator(name + ".o")
	d = {"int": 0, "float": 1}
	return sim.simulate()[d[t]]

def float_eq(f1, f2):
	# floating point value must be compared based on binary
	def float2bin(f):
		v = struct.pack('>f', f)
		v = struct.unpack('>I', v)[0]
		return format(v, '032b')

	assert len(f1) == 32
	print f1, float2bin(f2)
	return f1 == float2bin(f2)

def test_recfib13():
	# calculate recursive-fib(13)
	tb = "tests/fib"
	compile("tests/fib")
	expected = 233
	#assert csim(tb) == expected
	assert int(pysim(tb), 2) == expected

def test_ack_3_2():
	# calculate ack(3,2)
	tb = "tests/ack"
	compile(tb)
	expected = 29
	#assert csim(tb) == expected
	assert int(pysim(tb), 2) == expected

def test_gcd_216_3375():
	# caluculate gcd(216, 3375)
	tb = "tests/gcd"
	compile(tb)
	expected = 27
	#assert csim(tb) == expected
	assert int(pysim(tb), 2) == expected

def test_fadd():
	tb = "tests/fadd"
	compile(tb)
	expected = 2.9
	assert float_eq(pysim(tb, "float"), expected)

def test_fmul():
	tb = "tests/fmul"
	compile(tb)
	expected = 2.25
	assert float_eq(pysim(tb, "float"), expected)

def test_sin():
	tb = "tests/sin"
	compile(tb)
	expected = -1.0
	assert float_eq(pysim(tb, "float"), expected)

def test_sqrt():
	tb = "tests/sqrt"
	compile(tb)
	expected = 1.41421356
	assert float_eq(pysim(tb, "float"), expected)

def test_closure():
	tb = "tests/closure"
	compile(tb)
	expected = 10
	assert int(pysim(tb), 2) == expected

def test_cls_bug():
	tb = "tests/cls-bug"
	compile(tb)
	expected = 912
	assert int(pysim(tb), 2) == expected

if __name__ == "__main__":
	tb_name = sys.argv[1]
	print(pysim(tb_name))
