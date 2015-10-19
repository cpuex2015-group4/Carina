#!/usr/bin/env python
# coding: utf-8

import sys, os
import subprocess
from assembler.assembler import Assembler
from simulator.simulator import Simulator

MIN_CAML = os.path.join(os.path.dirname(os.path.abspath(__file__)), "min-caml/min-caml")

def execute(name):
	subprocess.call([MIN_CAML, name])
	asmblr = Assembler()
	asmblr.assemble(name + ".s")
	sim = Simulator(name + ".o")
	return sim.simulate()

def test_recfib13():
	# calculate recursive-fib(13)
	assert execute("tests/fib") == 233

def test_ack_3_5():
	# calculate ack(3,5)
	assert execute("tests/ack") == 253

def test_gcd_216_3375():
	# caluculate gcd(216, 3375)
	assert execute("tests/gcd") == 27

if __name__ == "__main__":
	tb_name = sys.argv[1]
	print(execute(tb_name))
