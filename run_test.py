#!/usr/bin/env python
# coding: utf-8

from assembler.assembler import Assembler
from simulator.main import simulate

def test_recfib13():
	# calculate recursive-fib(13)
	asmblr = Assembler()
	asmblr.assemble("tests/fib.s")
	assert simulate("tests/fib.o") == 233
