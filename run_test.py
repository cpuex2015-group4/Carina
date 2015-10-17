#!/usr/bin/env python
# coding: utf-8

from assembler.assembler import Assembler
from simulator.simulator import Simulator

def test_recfib13():
	# calculate recursive-fib(13)
	asmblr = Assembler()
	asmblr.assemble("tests/fib.s")
	sim = Simulator("tests/fib.o")
	assert sim.simulate() == 233
