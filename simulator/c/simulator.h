#ifndef SIMLULATOR_H
#define SIMLULATOR_H
#define SAFE_DELETE(x) {free(x);(x)=NULL;}

typedef unsigned int instruction;

typedef struct simulator_{
	int pc;
	int dynamic_inst_cnt;
	int* reg;
	float* f_reg;
	int fpcond;
	int Hi;
	int Lo; 
	int inst_cnt;
	instruction* inst_mem;
	int* mem;
	unsigned int binary_size;
	unsigned int data_size;
	unsigned int text_size;
	unsigned int entry_point;
}simulator;


typedef struct operands_{
	unsigned int reg_s_idx;
	unsigned int reg_t_idx;
	unsigned int reg_d_idx;
	int shamt;
	int imm;
	int adress;
	unsigned int ft_idx;
	unsigned int fs_idx;
	unsigned int fd_idx;
}operands;


simulator *init_sim();

void load_binary(simulator* sim, FILE* fp);

void simulate(simulator* sim_p);

void free_sim(simulator *sim);

#endif
