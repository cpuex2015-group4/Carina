#!/usr/bin/env python
# coding: utf-8

import os
import numpy as np
import matplotlib.pyplot as plt
from bind import *

TMP_ML = "python-tmp"

def clean():
	if os.path.exists(TMP_ML + ".ml"): os.remove(TMP_ML + ".ml")
	if os.path.exists(TMP_ML + ".s") : os.remove(TMP_ML + ".s")
	if os.path.exists(TMP_ML + ".o") : os.remove(TMP_ML + ".o")

def int_of_float(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("int_of_float({:f})".format(x))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}8D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[0])
	plt.plot(X, Y)
	plt.savefig("int_of_float.png")

def float_of_int(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("float_of_int({})".format(int(x)))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}8D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("float_of_int.png")

if __name__ == "__main__":
	X = np.arange(-10000, 10000, 10)
	clean()
#	int_of_float(X)
	float_of_int(X)
	clean()
