#!/usr/bin/env python
# coding: utf-8

import sys, os
import struct
import subprocess
from bind import *
import numpy as np
import matplotlib.pyplot as plt

TMP_ML = ".python-tmp"
X87 = os.path.join(os.path.dirname(os.path.abspath(__file__)), "x87.atan")

def sim_atan(x):
	with open(TMP_ML + ".ml", "w") as f:
		f.write("atan({:f})".format(x))
	compile(TMP_ML, quiet = True)
	return csim(TMP_ML)[1]

def x87_atan(x):
	p = subprocess.Popen([X87, str(x)],
		stdin  = subprocess.PIPE,
		stdout = subprocess.PIPE,
		stderr = subprocess.PIPE,
		shell = False)
	p.wait()
	return float(p.stdout.readlines()[0])

def iconv(x):
	v = struct.pack('>f', x)
	v = struct.unpack('>I', v)[0]
	return np.array(map(lambda x: int(x), list(format(v, '032b'))))

if __name__ == "__main__":
	if not os.path.exists(X87):
		sys.stderr.write("compile x87.atan\n$ gcc -o x87.atan x87.atan.c\n")
		sys.exit()

	x = 0
	dx = 0.01
	X = []
	err = []
	for i in range(1000):
		diff = iconv(sim_atan(x))-iconv(x87_atan(x))
		d = diff.nonzero()[0]
		if d.shape == (0,):
			e = 0
		else:
			e = 31 - d[0]
		X.append(x)
		err.append(e)
		x += dx
		sys.stderr.write("\033[20D\033[K{}".format(x))
	plt.plot(X, err)
	plt.xlabel("x")
	plt.ylabel("ulp(sim_atan - x87_atan)")
	plt.show()
