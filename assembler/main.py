#!/usr/bin/env python
# coding: utf-8

"""
Simple assemble script

Usage
---------
$ python /path/to/this_script [asm-file-name]

"""

import assembler
import sys

if __name__ == "__main__":
	filename = sys.argv[1]
	asmblr = assembler.Assembler()
	asmblr.assemble(filename)
