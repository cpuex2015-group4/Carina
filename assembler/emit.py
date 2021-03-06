#!/usr/bin/env python
# coding: utf-8

"""
emit program counter to assembly file
(ignore empty line, comment, pseudo-mnemonic, label)

[usage]

$ python emit.py [assembly-file]

"""

import sys
import re

SIGNATURE = "# emit.py executed\n"

if __name__ == "__main__":
	with open(sys.argv[1], "r") as ic:
		text = ic.readlines()
	
	if text[0] == SIGNATURE:
		sys.exit()

	pc = 0
	pat = re.compile(r"[^#]*:")
	for i in range(len(text)):
		t = text[i]
		if  t.strip() != "" \
		and t.strip()[0] != "#" \
		and ".data" not in t \
		and ".text" not in t \
		and ".long" not in t \
		and ".globl" not in t \
		and pat.match(t) is None:
			text[i] = "{}  # {}\n".format(t.rstrip('\n'), pc)
			pc += 1

	with open(sys.argv[1], "w") as oc:
		oc.write(SIGNATURE)
		oc.writelines(text)
