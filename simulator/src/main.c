#include<stdio.h>
#include<stdlib.h>
#include<string.h>

typedef unsigned int instruction;

typedef struct simulator_{
	int pc;
	unsigned int* reg;
	int inst_cnt;
	instruction* inst_mem;
	unsigned int* mem;
}simulator;

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

unsigned char get_binary(instruction inst, int start, int end)
{
	//printf("inst_int = %d\n", inst.inst_int);
	int len = end - start;
	//printf("%int", inst.inst_int);
	inst = inst << start;
	inst = inst >> (8 - len);
	return inst2char(inst, 0);
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

}

int simulate_inst(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char function_binary)
{
	if(operation_binary == 0 && function_binary == 32){
		puts("add");
	}else if(operation_binary == 8){
		puts("addi");
	}else if(operation_binary == 0 && function_binary == 36){
		puts("and_");
	}else if(operation_binary == 4){
		puts("beq");
	}else if(operation_binary == 5){
		puts("bne");
	}else if(operation_binary == 2){
		puts("j");
	}else if(operation_binary == 3){
		puts("jal");
	}else if(operation_binary == 0 && function_binary == 8){
		puts("jr");
	}else if(operation_binary == 35){
		puts("lw");
	}else if(operation_binary == 0 && function_binary == 39){
		puts("nor");
	}else if(operation_binary == 0 && function_binary == 37){
		puts("or_");
	}else if(operation_binary == 13){
		puts("ori");
	}else if(operation_binary == 0 && function_binary == 42){
		puts("slt");
	}else if(operation_binary == 10){
		puts("slti");
	}else if(operation_binary == 0 && function_binary == 0){
		puts("sll");
	}else if(operation_binary == 0 && function_binary == 2){
		puts("srl");
	}else if(operation_binary == 43){
		puts("sw");
	}else if(operation_binary == 0 && function_binary == 34){
		puts("sub");
	}else if(operation_binary == 63 && function_binary == 63){
		puts("htl");
	}
	return 0;
}

void simulate(simulator* sim_p)
{
	int i;
	instruction inst;
	unsigned char operation_binary;
	unsigned char function_binary;
	for(i = 0; i < sim_p->inst_cnt; i++){
		inst = 0;
		inst = load_char(inst, inst2char(sim_p->inst_mem[i], 0), 0);
		inst = load_char(inst, inst2char(sim_p->inst_mem[i], 1), 1);
		inst = load_char(inst, inst2char(sim_p->inst_mem[i], 2), 2);
		inst = load_char(inst, inst2char(sim_p->inst_mem[i], 3), 3);

		operation_binary = get_binary(inst, 0, 6);
		function_binary = get_binary(inst, 26, 32);
		simulate_inst(sim_p, inst, operation_binary, function_binary);
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
	simulator sim = {0, NULL,0, NULL, NULL};
	load_instruction(&sim, fp_binary);
	simulate(&sim);
	fclose(fp_binary);
	return 0;
}
