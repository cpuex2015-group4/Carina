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
	rvs = p.stdout.readlines()[1].split(",") #["int"+Vi, "float"+Vf]
	rvi = rvs[0].replace("int:", "")
	rvf = rvs[1].replace("float:", "")
	return (int(rvi), float(rvf))

def pysim(name, t = "int"):
	# execute on python simulator
	sim = Simulator(name + ".o")
	d = {"int": 0, "float": 1}
	return sim.simulate()[d[t]]

def float_eq(f1, f2):
	print(f1)
	print("---------------------")
	print(f2)
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
	assert csim(tb)[0] == expected
	assert int(pysim(tb), 2) == expected

def test_ack_3_2():
	# calculate ack(3,2)
	tb = "tests/ack"
	compile(tb)
	expected = 29
	assert csim(tb)[0] == expected
	assert int(pysim(tb), 2) == expected

def test_gcd_216_3375():
	# caluculate gcd(216, 3375)
	tb = "tests/gcd"
	compile(tb)
	expected = 27
	assert csim(tb)[0] == expected
	assert int(pysim(tb), 2) == expected

def test_fadd():
	tb = "tests/fadd"
	compile(tb)
	expected = 2.9
	#assert csim(tb)[1] == expected 
	assert float_eq(pysim(tb, "float"), expected)

def test_fmul():
	tb = "tests/fmul"
	compile(tb)
	expected = 2.25
	assert csim(tb)[1] == expected 
	assert float_eq(pysim(tb, "float"), expected)

def test_sin():
	tb = "tests/sin"
	compile(tb)
	expected = -1.0
	assert csim(tb)[1] == expected 
	assert float_eq(pysim(tb, "float"), expected)

def test_sqrt():
	tb = "tests/sqrt"
	compile(tb)
	expected = 1.41421356
	#assert csim(tb)[1] == expected 
	assert float_eq(pysim(tb, "float"), expected)

def test_closure():
	tb = "tests/closure"
	compile(tb)
	expected = 10
	assert csim(tb)[0] == expected 
	assert int(pysim(tb), 2) == expected

def test_cls_bug():
	tb = "tests/cls-bug"
	compile(tb)
	expected = 912
	assert csim(tb)[0] == expected 
	assert int(pysim(tb), 2) == expected

def test_cls_bug2():
	tb = "tests/cls-bug2"
	compile(tb)
	expected = 45
	assert csim(tb)[0] == expected 
	assert int(pysim(tb), 2) == expected

def test_spill():
	tb = "tests/spill"
	compile(tb)
	expected = -431
	assert csim(tb)[0] == expected
	assert int(pysim(tb), 2) == expected

def test_spill3():
	tb = "tests/spill3"
	compile(tb)
	expected = 1617
	assert csim(tb)[0] == expected
	assert int(pysim(tb), 2) == expected

if __name__ == "__main__":
	tb_name = sys.argv[1]
	print(pysim(tb_name))
