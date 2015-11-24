#!/usr/bin/env python
# coding: utf-8

"""
convert_coe
====

This script converts Carina object file into .coe file (Coefficients file),
which is the initial memory value for Block-RAM on FPGA.

.coe file is text based, and need two parameters:
+ MEMORY_INITIALIZATION_RADIX  ... in which radix .coe file is writtern
+ MEMORY_INITIALIZATION_VECTOR ... the content of whole BRAM

The difference between normal Carina object file and .coe file is as follows:
In the normal mode, Carina core waits on RS-232C in order to receive Carina object file.
At this moment, core first receives Carina header, and discards it then locate .text section at address 0x0.
However, if we use .coe file, Carina core needs the way to know header information.
Therefore when we use .coe file, we locate header at address 0x0 and .text at 0x10.
(Of course all label address must be relocated)

"""

import sys, os

def conv(data):
	assert len(data) == 4
	return (ord(data[0]) << 24) + (ord(data[1]) << 16) + (ord(data[2]) << 8) + ord(data[3])

def convert_coe(input_binary, output_coe, skip_header = True, bram_size = 32768):
	with open(input_binary) as carina_bin_file:
		carina_bin = carina_bin_file.read()

	if skip_header:
		offset = 16
	else:
		offset = 0
	carina_bin = [carina_bin[i:i+4] for i in range(offset, len(carina_bin), 4)]
	bin_size = len(carina_bin)

	with open(output_coe, "w") as carina_coe:
		carina_coe.write("MEMORY_INITIALIZATION_RADIX=16;\n")
		carina_coe.write("MEMORY_INITIALIZATION_VECTOR=\n")
		for i in range(bram_size):
			if i < bin_size:
				data = carina_bin[i]
				carina_coe.write("{:08x}{}\n".format(conv(data), "," if i+1 < bram_size else ";"))
			else:
				carina_coe.write("{:08x}{}\n".format(0, "," if i+1 < bram_size else ";"))

if __name__ == "__main__":
	if len(sys.argv) < 4:
		sys.stderr.write("usage: python convert_coe.py [input-binary] [output-coe] [BRAM-size]\n")
		sys.exit()

	convert_coe(sys.argv[1], sys.argv[2], int(sys.argv[3]))
