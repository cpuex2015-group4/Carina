#!/usr/bin/env python
# coding: utf-8

import sys, os
import subprocess
from assembler.assembler import Assembler
from simulator.python.simulator import Simulator

ROOT = os.path.dirname(os.path.abspath(__file__))
MIN_CAML = os.path.join(ROOT, "min-caml/min-caml")
CSIM = os.path.join(ROOT, "simulator/c/csim")

def assemble(name):
	subprocess.call([MIN_CAML, name])
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

def pysim(name):
	# execute on python simulator
	sim = Simulator(name + ".o")
	return sim.simulate()

def test_recfib13():
	# calculate recursive-fib(13)
	tb = "tests/fib"
	assemble("tests/fib")
	expected = 233
	assert csim(tb) == expected
	assert pysim(tb) == expected

def test_ack_3_2():
	# calculate ack(3,2)
	tb = "tests/ack"
	assemble(tb)
	expected = 29
#	assert csim(tb) == expected  # TODO: infinity loop!!!
	assert pysim(tb) == expected

def test_gcd_216_3375():
	# caluculate gcd(216, 3375)
	tb = "tests/gcd"
	assemble(tb)
	expected = 27
#	assert csim(tb) == expected
	assert pysim(tb) == expected

if __name__ == "__main__":
	tb_name = sys.argv[1]
	print(pysim(tb_name))
