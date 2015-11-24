#!/usr/bin/env python
# coding: utf-8

import sys
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
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
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
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("float_of_int.png")

def fcos(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("cos({:f})".format(x))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("cos.png")

def fsin(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("sin({:f})".format(x))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("sin.png")

def ftan(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("sin({0:f}) /. cos({0:f})".format(x))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("tan.png")

def fatan(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("atan({:f})".format(x))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("atan.png")

def fabs(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("fabs({:f})".format(x))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("fabs.png")

def floor(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("floor({:f})".format(x))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("floor.png")

def sqrt(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("sqrt({:f})".format(x))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("sqrt.png")

def inv(xran):
	Y = []
	sys.stdout.write("x = ")
	for x in xran:
		with open(TMP_ML + ".ml", "w") as f:
			f.write("1.0 /. ({:f})".format(x))
		compile(TMP_ML, quiet = True)
		sys.stdout.write("{0}20D{0}K{1:-8}".format("\033[", x))
		Y.append(csim(TMP_ML)[1])
	plt.plot(X, Y)
	plt.savefig("inv.png")


if __name__ == "__main__":
	X = np.arange(-10, 10, 0.1)
	spec = sys.argv[1]
	clean()
	if spec == "int_of_float":
		int_of_float(X)
	elif spec == "float_of_int":
		float_of_int(X)
	elif spec == "cos":
		fcos(X)
	elif spec == "sin":
		fsin(X)
	elif spec == "tan":
		ftan(X)
	elif spec == "atan":
		fatan(X)
	elif spec == "fabs":
		fabs(X)
	elif spec == "floor":
		floor(X)
	elif spec == "sqrt":
		sqrt(X)
	elif spec == "inv":
		inv(X)
	else:
		assert "invalid spec"
	clean()
