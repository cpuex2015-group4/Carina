#!/usr/bin/env python
# coding: utf-8

import sys, os

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(ROOT)

import subprocess
from assembler.assembler import Assembler
from simulator.python.simulator import Simulator

MIN_CAML = os.path.join(ROOT, "min-caml/min-caml")
CSIM = os.path.join(ROOT, "simulator/c/csim")

def compile(name, quiet=False):
	if quiet:
		p = subprocess.Popen([MIN_CAML, "-inline", "100", name],
				stdout = subprocess.PIPE,
				stderr = subprocess.PIPE,
				shell = False)
		ret_code = p.wait()
	else:
		ret_code = subprocess.call([MIN_CAML, "-inline", "100", name])
	if ret_code == 0:
		os.system("cat {}/min-caml/libmincaml.S >> {}.s".format(ROOT, name))
		os.system("cat {}/min-caml/read.S >> {}.s".format(ROOT, name))
		asmblr = Assembler()
		asmblr.assemble(name + ".s")
	else:
		assert False, "compile error"

def csim(name, stdin = None):
	# execute on c simulator
	if stdin is not None:
		stdin_pipe = open(stdin)
	else:
		stdin_pipe = subprocess.PIPE
	p = subprocess.Popen([CSIM, "-f" + name + ".o"],
			stdin  = stdin_pipe,
			stdout = subprocess.PIPE,
			stderr = subprocess.PIPE,
			shell = False)
	p.wait()
	# capture output in stdout as return value
	# output := int:[int_return],float:[float_return]
	rvs = p.stderr.readlines()[1].split(",") #["int"+Vi, "float"+Vf]
	rvi = rvs[0].replace("int:", "")
	rvf = rvs[1].replace("float:", "")
	if stdin is not None:
		stdin_pipe.close()
	return (int(rvi), float(rvf))

def pysim(name, t = "int", stdin = None):
	# execute on python simulator
	sim = Simulator(name + ".o", stdin = stdin)
	d = {"int": 0, "float": 1}
	return sim.simulate()[d[t]]

