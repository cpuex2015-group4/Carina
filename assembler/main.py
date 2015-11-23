#!/usr/bin/env python
# coding: utf-8

"""
Simple assemble script

Usage
---------
$ python /path/to/this_script [asm-file-name]

"""

import assembler
import convert_coe
import sys, os
import argparse

if __name__ == "__main__":
	parser = argparse.ArgumentParser(description = 'Carina assembler')

	parser.add_argument('filename', \
			action = 'store', \
			nargs = None, \
			type = str, \
			help = 'target assembly file')

	parser.add_argument('--coe', \
			action = 'store_true', \
			default = False, \
			help = 'output COE file (in default output binary)')

	parser.add_argument('--bram-size', \
			action = 'store', \
			default = 32768, \
			help = 'specify BRAM size (this option is valid only when --coe is specified)')

	args = parser.parse_args()

	asmblr = assembler.Assembler()
	asmblr.assemble(args.filename, args.coe)

	if args.coe:
		filebase, _ = os.path.splitext(args.filename)
		convert_coe.convert_coe(filebase + ".o", filebase + ".coe", args.bram_size)
