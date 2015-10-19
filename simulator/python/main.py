#!/usr/bin/env python
# coding: utf-8

"""
Simple simulator script

Usage
---------
$ python /path/to/this_script [exec-file-name]

"""
import sys
from argparse import ArgumentParser
from simulator import Simulator

if __name__ == "__main__":
	desc = u'{0} [Args] [Options]\nDetailed options -h or --help'.format(__file__)
	parser = ArgumentParser(description=desc)

	parser.add_argument(
		dest = 'filename',
		action = 'store',
		type = str,
		help = 'target testbench name')

	parser.add_argument(
		'-v', '--verbose',
		action = 'store_true',
		dest = 'verbose',
		help = "use verbose output")

	args = parser.parse_args()

	sim = Simulator(args.filename)
	v0 = sim.simulate(verbose = args.verbose)
	print("RESULT = {}".format(v0))
