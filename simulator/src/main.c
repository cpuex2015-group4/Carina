#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef unsigned int instruction;

typedef struct simulator_{
	int pc;
	int* reg;
	int inst_cnt;
	instruction* inst_mem;
	int* mem;
	unsigned int data_size;
	unsigned int text_size;
	unsigned int entry_point;
}simulator;

simulator init_sim()
{
	simulator sim;
	sim.pc = 0;
	sim.reg = (int*)malloc(sizeof(int) * 32);
	memset(sim.reg, 0, (sizeof(int) * 32));
	//stackpointer = reg[29]
	sim.reg[29] = 1000;
	sim.mem = malloc(1000000);
	return sim;
}

void print_int2bin(unsigned int n)
{
	char buf[32];
	int i;
	for(i = 0; i < 32; i++){
		if(n % 2 == 0){
			buf[i] = '0';
		}else{
			buf[i] = '1';
		}
		n = n >> 1;
	}
	for(i = 0; i < 32; i++){
		printf("%c", buf[31 - i]);
	}
	puts("");
	return;
}

void print_char2bin(unsigned char c)
{
	unsigned char buf[8];
	int i;
	for(i = 0; i < 8; i++){
		if(c % 2 == 0){
			buf[i] = '0';
		}else{
			buf[i] = '1';
		}
		c = c >> 1;
	}
	for(i = 0; i < 8; i++){
		printf("%c", buf[7 - i]);
	}
	puts("");
	return;
}

void print_reg(simulator* sim)
{
	int i;
	puts("------------------reg---------------");
	for(i = 0; i < 32; i++){
		printf("reg[i] = %d\n", sim->reg[i]);
	}
	puts("------------------------------------");
	return;
}

instruction load_char(instruction inst, unsigned char c, int idx)
{
	unsigned int tmp = (unsigned int)c;
	tmp = tmp << 24;
	tmp = tmp >> 8 * idx;
	inst = inst | tmp;
	return inst;
}

unsigned char inst2char(instruction inst, int idx)
{
	inst = inst << 8 * (idx);
	inst = inst >> 24;
	return (unsigned char)inst;
}

unsigned int get_binary(instruction inst, int start, int end)
{
	//printf("inst_int = %d\n", inst.inst_int);
	int len = end - start;
	//printf("%int", inst.inst_int);
	inst = inst << start;
	inst = inst >> (32 - len);
	return inst;
}

void load_instruction(simulator* sim, FILE* fp)
{
	unsigned char buf[1000000];
	int binary_size;
	binary_size = fread(buf, sizeof(unsigned char), 1000000, fp);
	sim->inst_mem = malloc(sizeof(unsigned char) * binary_size);
	memset(sim->inst_mem, 0, binary_size);
	sim->inst_cnt = (binary_size - 16) / 4;
	printf("binary_size = %d, inst_cnt = %d\n", binary_size, sim->inst_cnt);
	int i;
	int OFFSET = 16;

	sim->entry_point = load_char(sim->entry_point, buf[12], 0);
	sim->entry_point = load_char(sim->entry_point, buf[13], 1);
	sim->entry_point = load_char(sim->entry_point, buf[14], 2);
	sim->entry_point = load_char(sim->entry_point, buf[15], 3);
	sim->entry_point /= 4;
	printf("entry_point = %d\n", sim->entry_point);

	for(i = 0; i * 4 + OFFSET < binary_size; i++){
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 0 + OFFSET], 0);
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 1 + OFFSET], 1);
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 2 + OFFSET], 2);
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 3 + OFFSET], 3);
	}

  for(i=0; i < sim->inst_cnt; i++){
		if(i % 4 == 0){
			puts("");
		}
		printf("%02X ", inst2char(sim->inst_mem[i], 0)&0xff);
		printf("%02X ", inst2char(sim->inst_mem[i], 1)&0xff);
		printf("%02X ", inst2char(sim->inst_mem[i], 2)&0xff);
		printf("%02X ", inst2char(sim->inst_mem[i], 3)&0xff);
  }
	printf("\n");
	printf("instruction loaded\n");
	return;
}

int inst_add(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	unsigned int reg_d_idx = get_binary(inst, 16, 21);
	int reg_s = sim_p->reg[reg_s_idx];
	int reg_t = sim_p->reg[reg_t_idx];
	int reg_d = reg_s + reg_t;
	sim_p->reg[reg_d_idx] = reg_d;
	sim_p->pc++;
	return 1;
}

int inst_addi(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	int imm = get_binary(inst, 16, 32);
	int reg_t = sim_p->reg[reg_t_idx];
	sim_p->reg[reg_s_idx] = imm + reg_t;
	sim_p->pc++; 
	return 1;
}

int inst_and(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	unsigned int reg_d_idx = get_binary(inst, 16, 21);
	int reg_s = sim_p->reg[reg_s_idx];
	int reg_t = sim_p->reg[reg_t_idx];
	sim_p->reg[reg_d_idx] = reg_s & reg_t;
	sim_p->pc++;
	return 1;
}

int inst_beq(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	int imm = get_binary(inst, 16, 32);
	int reg_s = sim_p->reg[reg_s_idx];
	int reg_t = sim_p->reg[reg_t_idx];
	if(reg_s == reg_t){
		sim_p->pc += imm;
	}else{
		sim_p->pc++;
	}
	return 1;
}

int inst_bne(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	int imm = get_binary(inst, 16, 32);
	int reg_s = sim_p->reg[reg_s_idx];
	int reg_t = sim_p->reg[reg_t_idx];
	if(reg_s != reg_t){
		sim_p->pc += imm;
	}else{
		sim_p->pc++;
	}
	return 1;
}

int inst_j(simulator* sim_p, instruction inst)
{
	int imm = get_binary(inst, 6, 32);
	sim_p->pc += imm;
	return 1;
}

int inst_jal(simulator* sim_p, instruction inst)
{
	sim_p->reg[31] = (sim_p->pc + 1);
	int imm = get_binary(inst, 6, 32);
	sim_p->pc = imm;
	return 1;
}

int inst_jr(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	int reg_s = sim_p->reg[reg_s_idx];
	int pc_target = sim_p->mem[reg_s];
	sim_p->pc = pc_target;
	return 1;
}

int inst_lw(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	int imm = get_binary(inst, 16, 32);
	int reg_s = sim_p->reg[reg_s_idx];
	sim_p->reg[reg_t_idx] = sim_p->mem[reg_s + imm];
	sim_p->pc++;
	return 1;
}

int inst_nor(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	unsigned int reg_d_idx = get_binary(inst, 16, 21);
	int reg_s = sim_p->reg[reg_s_idx];
	int reg_t = sim_p->reg[reg_t_idx];
	sim_p->reg[reg_d_idx] = ~(reg_s | reg_t);
	sim_p->pc++;
	return 1;
}

int inst_or(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	unsigned int reg_d_idx = get_binary(inst, 16, 21);
	int reg_s = sim_p->reg[reg_s_idx];
	int reg_t = sim_p->reg[reg_t_idx];
	sim_p->reg[reg_d_idx] = (reg_s | reg_t);
	sim_p->pc++;
	return 1;
}

int inst_ori(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	int imm = get_binary(inst, 16, 32);
	int reg_s = sim_p->reg[reg_s_idx];
	sim_p->reg[reg_t_idx] = (reg_s | imm);
	sim_p->pc++;
	return 1;
}

int inst_slt(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	unsigned int reg_d_idx = get_binary(inst, 16, 21);
	int reg_s = sim_p->reg[reg_s_idx];
	int reg_t = sim_p->reg[reg_t_idx];
	if(reg_s < reg_t){
		sim_p->reg[reg_d_idx] = 1;
	}else{
		sim_p->reg[reg_d_idx] = 0;
	}
	sim_p->pc++;
	return 1;
}

int inst_slti(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	int imm = get_binary(inst, 16, 32);
	int reg_s = sim_p->reg[reg_s_idx];
	if(reg_s < imm){
		sim_p->reg[reg_t_idx] = 1;
	}else{
		sim_p->reg[reg_t_idx] = 0;
	}
	sim_p->pc++;
	return 1;
}

int inst_sll(simulator* sim_p, instruction inst)
{
	unsigned int reg_t_idx = get_binary(inst, 6, 11);
	unsigned int reg_d_idx = get_binary(inst, 11, 16);
	int reg_t = sim_p->reg[reg_t_idx];
	int shamt = get_binary(inst, 21, 26);
	sim_p->reg[reg_d_idx] = reg_t << shamt;
	sim_p->pc++;
	return 1;
}

int inst_srl(simulator* sim_p, instruction inst)
{
	unsigned int reg_t_idx = get_binary(inst, 6, 11);
	unsigned int reg_d_idx = get_binary(inst, 11, 16);
	int reg_t = sim_p->reg[reg_t_idx];
	int shamt = get_binary(inst, 21, 26);
	sim_p->reg[reg_d_idx] = reg_t >> shamt;
	sim_p->pc++;
	return 1;

}

int inst_sw(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	int imm = get_binary(inst, 16, 32);
	int reg_s = sim_p->reg[reg_s_idx];
	int reg_t = sim_p->reg[reg_t_idx];
	printf("reg_s = %d\n", reg_s);
	printf("imm = %d\n", imm);
	sim_p->mem[reg_s + imm] = reg_t; 
	sim_p->pc++;
	return 1;
}

int inst_sub(simulator* sim_p, instruction inst)
{
	unsigned int reg_s_idx = get_binary(inst, 6, 11);
	unsigned int reg_t_idx = get_binary(inst, 11, 16);
	unsigned int reg_d_idx = get_binary(inst, 16, 21);
	int reg_s = sim_p->reg[reg_s_idx];
	int reg_t = sim_p->reg[reg_t_idx];
	int reg_d = reg_s - reg_t;
	sim_p->reg[reg_d_idx] = reg_d;
	sim_p->pc++;
	return 1;
}

int inst_hlt(simulator* sim_p, instruction inst)
{
	return 0;
}


int simulate_inst(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char function_binary)
{
	if(operation_binary == 0 && function_binary == 32){
		puts("add");
		return inst_add(sim_p, inst);
	}else if(operation_binary == 8){
		puts("addi");
		return inst_addi(sim_p, inst);
	}else if(operation_binary == 0 && function_binary == 36){
		puts("and_");
		return inst_and(sim_p, inst);
	}else if(operation_binary == 4){
		puts("beq");
		return inst_beq(sim_p, inst);
	}else if(operation_binary == 5){
		puts("bne");
		return inst_bne(sim_p, inst);
	}else if(operation_binary == 2){
		puts("j");
		return inst_j(sim_p, inst);
	}else if(operation_binary == 3){
		puts("jal");
		return inst_jal(sim_p, inst);
	}else if(operation_binary == 0 && function_binary == 8){
		puts("jr");
		return inst_jr(sim_p, inst);
	}else if(operation_binary == 35){
		puts("lw");
		return inst_lw(sim_p, inst);
	}else if(operation_binary == 0 && function_binary == 39){
		puts("nor");
		return inst_nor(sim_p, inst);
	}else if(operation_binary == 0 && function_binary == 37){
		puts("or_");
		return inst_or(sim_p, inst);
	}else if(operation_binary == 13){
		puts("ori");
		return inst_ori(sim_p, inst);
	}else if(operation_binary == 0 && function_binary == 42){
		puts("slt");
		return inst_slt(sim_p, inst);
	}else if(operation_binary == 10){
		puts("slti");
		return inst_slti(sim_p, inst);
	}else if(operation_binary == 0 && function_binary == 0){
		puts("sll");
		return inst_sll(sim_p, inst);
	}else if(operation_binary == 0 && function_binary == 2){
		puts("srl");
		return inst_srl(sim_p, inst);
	}else if(operation_binary == 43){
		puts("sw");
		return inst_sw(sim_p, inst);
	}else if(operation_binary == 0 && function_binary == 34){
		puts("sub");
		return inst_sub(sim_p, inst);
	}else if(operation_binary == 63 && function_binary == 63){
		puts("hlt");
		return inst_hlt(sim_p, inst);
	}
	return 0;
}

void simulate(simulator* sim_p)
{
	instruction inst;
	unsigned char operation_binary;
	unsigned char function_binary;
	int res = 0;
	//print_reg(sim_p);
	sim_p->pc = sim_p->entry_point;
	while(1){
		printf("PC = %d\n", sim_p->pc);
		inst = 0;
		inst = load_char(inst, inst2char(sim_p->inst_mem[sim_p->pc], 0), 0);
		inst = load_char(inst, inst2char(sim_p->inst_mem[sim_p->pc], 1), 1);
		inst = load_char(inst, inst2char(sim_p->inst_mem[sim_p->pc], 2), 2);
		inst = load_char(inst, inst2char(sim_p->inst_mem[sim_p->pc], 3), 3);

		operation_binary = get_binary(inst, 0, 6);
		function_binary = get_binary(inst, 26, 32);
		res = simulate_inst(sim_p, inst, operation_binary, function_binary);
		//print_reg(sim_p);
		if(res == 0){
			break;
		}else{
			continue;
		}
	}
}

int main(int argc, char* argvs[])
{
	char* filename_binary = argvs[1];
	FILE* fp_binary;
	if ((fp_binary = fopen(filename_binary, "rb")) == NULL) {
		printf("file open error!!\n");
		exit(EXIT_FAILURE);
	}

	simulator sim = init_sim();
	load_instruction(&sim, fp_binary);
	simulate(&sim);
	fclose(fp_binary);
	return 0;
}
