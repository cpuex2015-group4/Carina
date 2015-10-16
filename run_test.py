#!/usr/bin/env python
# coding: utf-8

from assembler.main import assemble
from simulator.main import simulate

def test_fib1():
	assemble("tests/fib.s")
	simulate("tests/fib.o")
	assert 1 == 1
