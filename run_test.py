#!/usr/bin/env python
# coding: utf-8

from assembler.main import assemble
from simulator.main import simulate

def test_fib1():
	# calculate fib(20)
	assemble("tests/fib.s")
	assert simulate("tests/fib.o") == 6765
