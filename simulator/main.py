#!/usr/bin/env python
# coding: utf-8

import sys
import simulate as sim

def simulate(filename):
	with open(filename, "rb") as file_in:
		sim.Simulator.load_instruction(file_in.read())

	#print(sim.Simulator.inst_mem)
	sim.Simulator.initialization()
	inst_cnt = 0
	while(True):
		inst = sim.Simulator.inst_mem[sim.Simulator.pc]
		res = sim.Simulator.fecth_instruction(inst)
		inst_cnt += 1
		if(res == 0):
			break
		else:
			continue
	#print("instruction : " + str(inst_cnt))

	# return the content of %v0
	return int(sim.Simulator.reg["00010"], 2)

if __name__ == "__main__":
	filename = sys.argv[1]
	print("RESULT = {}".format(simulate(filename)))
