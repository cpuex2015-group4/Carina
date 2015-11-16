#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./utils.h"
#include "./simulator.h"

extern int simulate_inst(simulator* , instruction, unsigned char, unsigned char, unsigned char, unsigned char);

int simulate_inst_debug(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char fmt_binary, unsigned char ft_binary, unsigned char function_binary){
	return simulate_inst(sim_p, inst, operation_binary, fmt_binary, ft_binary, function_binary);
}

