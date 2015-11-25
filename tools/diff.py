#!/usr/bin/env python
# coding: utf-8

import sys, os
import struct
import subprocess
from bind import *
import numpy as np
import matplotlib.pyplot as plt

TMP_ML = ".python-tmp"
X87 = os.path.join(os.path.dirname(os.path.abspath(__file__)), "x87")

def sim(s, x):
	with open(TMP_ML + ".ml", "w") as f:
		if s == "sin":
			f.write("sin({:f})".format(x))
		elif s == "cos":
			f.write("cos({:f})".format(x))
		elif s == "tan":
			f.write("sin({0:f}) /. cos({0:f})".format(x))
		elif s == "atan":
			f.write("atan({:f})".format(x))
		elif s == "sqrt":
			f.write("sqrt({:f})".format(x))
		elif s == "float_of_int":
			f.write("float_of_int({})".format(x))
	compile(TMP_ML, quiet = True)
	return csim(TMP_ML)[1]

def x87(s, x):
	p = subprocess.Popen([X87, s, str(x)],
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

	if not os.path.exists(X87):
		sys.stderr.write("compile x87\n$ gcc -o x87 x87.c\n")
		sys.exit()

	basic = ["sin", "cos", "tan", "atan", "sqrt"]

	if s in basic:
		x = 0
		dx = 0.01
		X = []
		err = []
		for i in range(1000):
			diff = np.abs(iconv(sim(s, x))-iconv(x87(s, x)))
			X.append(x)
			err.append(diff)
			x += dx
			sys.stderr.write("\033[20D\033[K{}".format(x))
		plt.plot(X, err)
		plt.xlabel("x")
		plt.ylabel("ulp(sim_{0} - x87_{0})".format(s))
	else:
		x = -500 
		dx = 1
		X = []
		err = []
		for i in range(1000):
			diff = np.abs(iconv(sim(s, x))-iconv(x87(s, x)))
			X.append(x)
			err.append(diff)
			x += dx
			sys.stderr.write("\033[20D\033[K{}".format(x))
		plt.plot(X, err)
		plt.xlabel("x")
		plt.ylabel("ulp(sim_{0} - x87_{0})".format(s))
	plt.show()
