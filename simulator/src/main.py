import sys
import simulate as sim

file_in = open(sys.argv[1], "rb")

sim.Simulator.load_instruction(file_in.read())
file_in.close()
print(sim.Simulator.inst_mem)
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
print("instruction : " + str(inst_cnt))
