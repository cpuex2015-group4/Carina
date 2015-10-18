import sys
import simulate as sim
from simulate import Simulator as Sim

file_in = open(sys.argv[1], "rb")

Sim.load_instruction(file_in.read())
file_in.close()
Sim.initialization()
inst_cnt = 0
while(True):
	inst = Sim.inst_mem[sim.Simulator.pc]
	res = Sim.fecth_instruction(inst)
	inst_cnt += 1
	if(res == 0):
		break
	else:
		continue
print("instruction : " + str(inst_cnt))
