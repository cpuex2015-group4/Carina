#!/usr/bin/env python
# coding: utf-8

import sys, os
import struct
import subprocess
from bind import *
import numpy as np
import matplotlib.pyplot as plt

TMP_ML = ".python-tmp"
X87SQRT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "x87.sqrt")
X87ATAN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "x87.atan")
X87SIN = os.path.join(os.path.dirname(os.path.abspath(__file__)), "x87.sin")

def sim_sqrt(x):
	with open(TMP_ML + ".ml", "w") as f:
		f.write("sqrt({:f})".format(x))
	compile(TMP_ML, quiet = True)
	return csim(TMP_ML)[1]

def x87_sqrt(x):
	p = subprocess.Popen([X87SQRT, str(x)],
		stdin  = subprocess.PIPE,
		stdout = subprocess.PIPE,
		stderr = subprocess.PIPE,
		shell = False)
	p.wait()
	return float(p.stdout.readlines()[0])

def sim_atan(x):
	with open(TMP_ML + ".ml", "w") as f:
		f.write("atan({:f})".format(x))
	compile(TMP_ML, quiet = True)
	return csim(TMP_ML)[1]

def x87_atan(x):
	p = subprocess.Popen([X87ATAN, str(x)],
		stdin  = subprocess.PIPE,
		stdout = subprocess.PIPE,
		stderr = subprocess.PIPE,
		shell = False)
	p.wait()
	return float(p.stdout.readlines()[0])

def sim_sin(x):
	with open(TMP_ML + ".ml", "w") as f:
		f.write("sin({:f})".format(x))
	compile(TMP_ML, quiet = True)
	return csim(TMP_ML)[1]

def x87_sin(x):
	p = subprocess.Popen([X87SIN, str(x)],
		stdin  = subprocess.PIPE,
		stdout = subprocess.PIPE,
		stderr = subprocess.PIPE,
		shell = False)
	p.wait()
	return float(p.stdout.readlines()[0])

def iconv(x):
	v = struct.pack('>f', x)
	v = struct.unpack('>I', v)[0]
	return v 

if __name__ == "__main__":
	s = sys.argv[1]

	if s == "sqrt":
		if not os.path.exists(X87SQRT):
			sys.stderr.write("compile x87.sqrt\n$ gcc -o x87.sqrt x87.sqrt.c\n")
			sys.exit()
		sim = sim_sqrt
		x87 = x87_sqrt
	elif s == "atan":
		if not os.path.exists(X87ATAN):
			sys.stderr.write("compile x87.atan\n$ gcc -o x87.atan x87.atan.c\n")
			sys.exit()
		sim = sim_atan
		x87 = x87_atan
	elif s == "sin":
		if not os.path.exists(X87SIN):
			sys.stderr.write("compile x87.sin\n$ gcc -o x87.sin x87.sin.c\n")
			sys.exit()
		sim = sim_sin
		x87 = x87_sin

	x = 0
	dx = 0.01
	X = []
	err = []
	for i in range(1000):
		diff = np.abs(iconv(sim(x))-iconv(x87(x)))
		X.append(x)
		err.append(diff)
		x += dx
		sys.stderr.write("\033[20D\033[K{}".format(x))
	plt.plot(X, err)
	plt.xlabel("x")
	plt.ylabel("ulp(sim_{0} - x87_{0})".format(s))
	plt.show()
