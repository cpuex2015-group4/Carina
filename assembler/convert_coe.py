#!/usr/bin/env python
# coding: utf-8

import sys, os

def conv(data):
	assert len(data) == 4
	return (ord(data[0]) << 24) + (ord(data[1]) << 16) + (ord(data[2]) << 8) + ord(data[3])

if __name__ == "__main__":
	if len(sys.argv) < 4:
		sys.stderr.write("usage: python convert_coe.py [input-binary] [output-coe] [BRAM-size]\n")
		sys.exit()

	with open(sys.argv[1]) as carina_bin_file:
		carina_bin = carina_bin_file.read()

	carina_bin = [carina_bin[i:i+4] for i in range(16, len(carina_bin), 4)]
	bin_size = len(carina_bin)
	bram_size = int(sys.argv[3])

	with open(sys.argv[2], "w") as carina_coe:
		carina_coe.write("MEMORY_INITIALIZATION_RADIX=16\n")
		carina_coe.write("MEMORY_INITIALIZATION_VECTOR=\n")
		for i in range(bram_size):
			if i < bin_size:
				data = carina_bin[i]
				carina_coe.write("{:08x}{}\n".format(conv(data), "," if i+1 < bram_size else ";"))
			else:
				carina_coe.write("{:08x}{}\n".format(0, "," if i+1 < bram_size else ";"))
