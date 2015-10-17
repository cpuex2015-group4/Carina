#!/usr/bin/env python
# coding: utf-8

"""
Simple simulator script

Usage
---------
$ python /path/to/this_script [exec-file-name]

"""
import sys
from simulator import Simulator

if __name__ == "__main__":
	filename = sys.argv[1]
	sim = Simulator(filename)
	v0 = sim.simulate()
	print("RESULT = {}".format(v0))
