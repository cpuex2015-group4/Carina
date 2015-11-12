#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./utils.h"
#include "./simulator.h"

extern int IS_DEBUG;
extern int MEM_SIZE;

char* REG_ARR[] = {""};

simulator *init_sim()
{
	int i;
	simulator *sim = (simulator *)malloc(sizeof(simulator));
	sim->pc = 0;
	sim->dynamic_inst_cnt = 0;
	sim->fpcond = 0;
	sim->reg = (int*)malloc(sizeof(int) * 32);
	sim->f_reg = (float*)malloc(sizeof(float) * 32);
	for(i = 0; i < 32; i++){
		sim->f_reg[i] = 0.0;
	}
	memset(sim->reg, 0, (sizeof(int) * 32));
	//memset(sim->f_reg, 0, (sizeof(float) * 32));
	sim->reg[29] = 100; //stackpointer = reg[29]
	sim->mem = calloc(sizeof(int), MEM_SIZE);
	return sim;
}

void free_sim(simulator *sim) {
	SAFE_DELETE(sim->reg);
	SAFE_DELETE(sim->f_reg);
	SAFE_DELETE(sim->mem);
	SAFE_DELETE(sim);
}

void print_mem(simulator* sim)
{
	int i;
	for(i = 0; i < MEM_SIZE; i++){
		if(sim->mem[i] != 0){
			printf("mem[%d] = %d\n", i, sim->mem[i]);
		}
	}
	return;
}

void print_reg(simulator* sim)
{
	int i;
	puts("------------------reg---------------");
	for(i = 0; i < 32; i++){
		printf("reg[%d] = %d\n", i, sim->reg[i]);
	}
	puts("------------------------------------");
	return;
}

void print_f_reg(simulator* sim)
{
	int i;
	puts("------------------reg---------------");
	for(i = 0; i < 32; i++){
		printf("freg[%d] = %f\n", i, sim->f_reg[i]);
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

void load_header(simulator* sim, unsigned char* buf)
{
	sim->text_size = load_char(sim->text_size, buf[4], 0);
	sim->text_size = load_char(sim->text_size, buf[5], 1);
	sim->text_size = load_char(sim->text_size, buf[6], 2);
	sim->text_size = load_char(sim->text_size, buf[7], 3);
	
	sim->data_size = load_char(sim->data_size, buf[8], 0);
	sim->data_size = load_char(sim->data_size, buf[9], 1);
	sim->data_size = load_char(sim->data_size, buf[10], 2);
	sim->data_size = load_char(sim->data_size, buf[11], 3);

	sim->entry_point = load_char(sim->entry_point, buf[12], 0);
	sim->entry_point = load_char(sim->entry_point, buf[13], 1);
	sim->entry_point = load_char(sim->entry_point, buf[14], 2);
	sim->entry_point = load_char(sim->entry_point, buf[15], 3);
	if(IS_DEBUG){
		printf("text_size = %d\n", sim->text_size);
		printf("data_size = %d\n", sim->data_size);
	}
	return;
}

void load_instruction(simulator* sim, unsigned char* buf)
{
	int OFFSET = 16;
	int i;
	for(i = 0; i < sim->text_size; i++){
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 0 + OFFSET], 0);
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 1 + OFFSET], 1);
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 2 + OFFSET], 2);
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 3 + OFFSET], 3);
	}
	return;
}

void load_data(simulator* sim, unsigned char* buf)
{
	int OFFSET = 16;
	int i;
	int data;
	if(IS_DEBUG){
		printf("sim->binary_size = %d\n", sim->binary_size);
		printf("sim->text_size = %d\n", sim->text_size);
	}

	for(i = 0; (i + sim->text_size) * 4 + OFFSET < sim->binary_size; i++){
		memset(&data, 0, 4);
		data = load_char(data, buf[(i + sim->text_size) * 4 + 0 + OFFSET], 0);
		data = load_char(data, buf[(i + sim->text_size) * 4 + 1 + OFFSET], 1);
		data = load_char(data, buf[(i + sim->text_size) * 4 + 2 + OFFSET], 2);
		data = load_char(data, buf[(i + sim->text_size) * 4 + 3 + OFFSET], 3);
		sim->mem[(sim->text_size + i)] = data;
	}
	return;
}

void load_binary(simulator* sim, FILE* fp)
{
	unsigned char buf[1000000];
	int binary_size;
	binary_size = fread(buf, sizeof(unsigned char), 1000000, fp);
	sim->binary_size = binary_size;
	sim->inst_mem = malloc(sizeof(unsigned char) * binary_size);
	sim->reg[28] = sim->text_size + sim->data_size; //heap pointer 
	memset(sim->inst_mem, 0, binary_size);
	//printf("binary_size = %d, inst_cnt = %d\n", binary_size, sim->inst_cnt);
	load_header(sim, buf);
	load_instruction(sim, buf);
	load_data(sim, buf);
	if(IS_DEBUG) print_mem(sim);
	return;
}

void print_operands(operands ops, int option)
{
	/*
	 * option
	 * --------
	 * 0 - decode_R
	 * 1 - decode_I
	 * 2 - decode_J
	 * 3 - decode_FR
	 * 4 - decode_FI
	 */
	if(IS_DEBUG){
	}else{
		switch(option){
			case 0:
				break;
			case 1:
				break;
			case 2:
				break;
			case 3:
				break;
			case 4:
				break;
		}
	}
	return;	
}

operands decode_R(instruction inst)
{
	operands ops;
	if(IS_DEBUG)print_operands(ops, 0);
	ops.reg_s_idx = get_binary_unsigned(inst, 6, 11);
	ops.reg_t_idx = get_binary_unsigned(inst, 11, 16);
	ops.reg_d_idx = get_binary_unsigned(inst, 16, 21);
	ops.shamt = get_binary_unsigned(inst, 21, 26);
	return ops;
}

operands decode_I(instruction inst)
{
	operands ops;
	if(IS_DEBUG)print_operands(ops, 1);
	ops.reg_s_idx = get_binary_unsigned(inst, 6, 11);
	ops.reg_t_idx = get_binary_unsigned(inst, 11, 16);
	ops.imm = get_binary_signed(inst, 16, 32);
	return ops;
}

operands decode_J(instruction inst)
{
	operands ops;
	if(IS_DEBUG)print_operands(ops, 2);
	ops.imm = get_binary_signed(inst, 6, 32);
	return ops;
}

operands decode_FR(instruction inst)
{
	operands ops;
	if(IS_DEBUG)print_operands(ops, 3);
	ops.ft_idx = get_binary_unsigned(inst, 11, 16);
	ops.fs_idx = get_binary_unsigned(inst, 16, 21);
	ops.fd_idx = get_binary_unsigned(inst, 21, 26);
	return ops;
}

operands decode_FI(instruction inst)
{
	operands ops;
	if(IS_DEBUG)print_operands(ops, 4);
	ops.ft_idx = get_binary_unsigned(inst, 11, 16);
	ops.imm = get_binary_signed(inst, 16, 32);
	return ops;
}

int inst_add(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("add\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	int reg_d = reg_s + reg_t;
	sim_p->reg[ops.reg_d_idx] = reg_d;
	sim_p->pc++;
	return 1;
}

int inst_addi(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("addi\n");}
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->reg[ops.reg_t_idx] = ops.imm + reg_s;
	sim_p->pc++; 
	return 1;
}

int inst_and(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("and\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	int reg_d = reg_s & reg_t;
	sim_p->reg[ops.reg_d_idx] = reg_d;
	sim_p->pc++;
	return 1;
}

int inst_beq(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("beq\n");}
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	if(IS_DEBUG){
		printf("reg_s = %d\n", reg_s);
		printf("reg_t = %d\n", reg_t);
	}
	if(reg_s == reg_t){
		sim_p->pc += ops.imm;
	}
	sim_p->pc++;
	return 1;
}

int inst_bne(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("bne\n");}
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	if(reg_s != reg_t){
		sim_p->pc += ops.imm;
	}
	sim_p->pc++;
	return 1;
}

int inst_j(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("j\n");}
	operands ops = decode_J(inst);
	sim_p->pc = ops.imm;
	return 1;
}

int inst_jal(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("jal\n");}
	sim_p->reg[31] = ((sim_p->pc + 1));
	operands ops = decode_J(inst);
	if(IS_DEBUG)printf("ops.imm = %d\n", ops.imm);
	sim_p->pc = ops.imm;
	return 1;
}

int inst_jr(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("jr\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->pc = reg_s;
	return 1;
}

int inst_jral(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("jral\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->reg[31] = (sim_p->pc + 1);
	sim_p->pc = reg_s;
	return 1;
}

int inst_lw(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("lw\n");}
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->reg[ops.reg_t_idx] = sim_p->mem[reg_s + ops.imm];
	sim_p->pc++;
	return 1;
}

int inst_nor(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("nor\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->reg[ops.reg_d_idx] = ~(reg_s | reg_t);
	sim_p->pc++;
	return 1;
}

int inst_or(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("or\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->reg[ops.reg_d_idx] = (reg_s | reg_t);
	sim_p->pc++;
	return 1;
}

int inst_ori(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("ori\n");}
	operands ops = decode_I(inst);
	int imm = get_binary_signed(inst, 16, 32);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->reg[ops.reg_t_idx] = (reg_s | imm);
	sim_p->pc++;
	return 1;
}

int inst_slt(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("slt\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	if(IS_DEBUG){
		printf("reg_s = %d\n", reg_s);
		printf("reg_t = %d\n", reg_t);
	}
	if(reg_s < reg_t){
		sim_p->reg[ops.reg_d_idx] = 1;
	}else{
		sim_p->reg[ops.reg_d_idx] = 0;
	}
	sim_p->pc++;
	return 1;
}

int inst_slti(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("slti\n");}
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	if(reg_s < ops.imm){
		sim_p->reg[ops.reg_t_idx] = 1;
	}else{
		sim_p->reg[ops.reg_t_idx] = 0;
	}
	sim_p->pc++;
	return 1;
}

int inst_sll(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("sll\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->reg[ops.reg_d_idx] = reg_s << ops.shamt;
	sim_p->pc++;
	return 1;
}

int inst_srl(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("srl\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->reg[ops.reg_d_idx] = reg_s >> ops.shamt;
	sim_p->pc++;
	return 1;
}

int inst_sw(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("sw\n");}
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->mem[reg_s + ops.imm] = reg_t; 
	sim_p->pc++;
	return 1;
}

int inst_sub(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("sub\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	int reg_d = reg_s - reg_t;
	sim_p->reg[ops.reg_d_idx] = reg_d;
	sim_p->pc++;
	return 1;
}

int inst_bclt(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("bclt\n");}
	operands ops = decode_FI(inst);
	if(sim_p->fpcond){
		sim_p->pc += ops.imm;
	}
	sim_p->pc++;
	return 1;
}
int inst_bclf(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("bclf\n");}
	operands ops = decode_FI(inst);
	if(!sim_p->fpcond){
		sim_p->pc += ops.imm;
	}
	sim_p->pc ++;
	return 1;
}

int inst_div(simulator* sim_p, instruction inst)
{
	/*
	if(IS_DEBUG){printf("div\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->Lo = reg_s / reg_t;
	sim_p->Hi = reg_s % reg_t;
	sim_p->pc++;
	return 1;
	*/
	if(IS_DEBUG){printf("div\n");}
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	int reg_d = reg_s / reg_t;
	sim_p->reg[ops.reg_d_idx] = reg_d;
	sim_p->pc++;
	return 1;
}

int inst_adds(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("adds\n");}
	operands ops = decode_FR(inst);
	if(IS_DEBUG){
		printf("ops.ft_idx = %d\n", ops.ft_idx);
		printf("ops.fs_idx = %d\n", ops.fs_idx);
	}
	float ft = sim_p->f_reg[ops.ft_idx];
	float fs = sim_p->f_reg[ops.fs_idx];
	float fd = fs + ft;
	if(IS_DEBUG)printf("FADD %f + %f = %f\n", ft, fs, fd);
	sim_p->f_reg[ops.fd_idx] = fd;
	sim_p->pc++;
	return 1;
}

int inst_cs(simulator* sim_p, instruction inst, int option)
{
	if(IS_DEBUG){printf("cs\n");}
	/*
	 * option
	 * -----------
	 *  0->EQ
	 *  1->LT
	 *  2->LE
	 */
	operands ops = decode_FR(inst);
	float ft = sim_p->f_reg[ops.ft_idx];
	float fs = sim_p->f_reg[ops.fs_idx];
	if(option == 0)
		sim_p->fpcond = ft==fs? 1 : 0;

	if(option == 1)
		sim_p->fpcond = ft<fs? 1 : 0;

	if(option == 2)
		sim_p->fpcond = ft<=fs? 1 : 0;

	sim_p->pc++;
	return 1;
}

int inst_muls(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("muls\n");}
	operands ops = decode_FR(inst);
	float ft = sim_p->f_reg[ops.ft_idx];
	float fs = sim_p->f_reg[ops.fs_idx];
	float fd = fs * ft;
	if(IS_DEBUG)printf("FMUL %f * %f = %f\n", fs, ft, fd);
	sim_p->f_reg[ops.fd_idx] = fd;
	sim_p->pc++;
	return 1;
}

int inst_invs(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("invs\n");}
	operands ops = decode_FR(inst);
	float ft = sim_p->f_reg[ops.ft_idx];
	float fd = (1.0 / ft);
	if(IS_DEBUG) printf("FINV 1.0 / %f = %f\n", ft, fd); 
	sim_p->f_reg[ops.fd_idx] = fd;
	sim_p->pc++;
	return 1;
}

int inst_divs(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("divs\n");}
	operands ops = decode_FR(inst);
	float ft = sim_p->f_reg[ops.ft_idx];
	float fs = sim_p->f_reg[ops.fs_idx];
	float fd = fs / ft;
	sim_p->f_reg[ops.fd_idx] = fd;
	sim_p->pc++;
	return 1;
}

int inst_subs(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("subs\n");}
	operands ops = decode_FR(inst);
	float ft = sim_p->f_reg[ops.ft_idx];
	float fs = sim_p->f_reg[ops.fs_idx];
	float fd = fs - ft;
	sim_p->f_reg[ops.fd_idx] = fd;
	sim_p->pc++;
	return 1;
}

int inst_lws(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("lws\n");}
	operands ops = decode_I(inst);
	float ft = int2float(sim_p->mem[sim_p->reg[ops.reg_s_idx] + ops.imm]);
	//if(IS_DEBUG)printf("ft = %f\n", ft);
	//if(IS_DEBUG)printf("ops.reg_t_idx = %d\n", ops.reg_t_idx);
	sim_p->f_reg[ops.reg_t_idx] = ft;
	sim_p->pc++;
	return 1;
}

int inst_mult(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("mult\n");} 
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	int reg_d = reg_s * reg_t;
	sim_p->reg[ops.reg_d_idx] = reg_d;
	sim_p->pc++;
	return 1;
}

int inst_sws(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("sws\n");}
	operands ops = decode_I(inst);
	float ft = sim_p->f_reg[ops.reg_t_idx];
	sim_p->mem[sim_p->reg[ops.reg_s_idx] + ops.imm] = float2int(ft);
	sim_p->pc++;
	return 1;
}

int inst_in_(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("in\n");} 
	operands ops = decode_R(inst);
	char in_;
	in_ = getchar();
	sim_p->reg[ops.reg_t_idx] = (unsigned int)in_;
	sim_p->pc++;
	return 1;
}

int inst_out(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("out\n");} 
	operands ops = decode_R(inst);
	printf("%c\n", (char)sim_p->reg[ops.reg_t_idx]);
	sim_p->pc++;
	return 1;
}

int inst_hlt(simulator* sim_p, instruction inst)
{
	if(IS_DEBUG){printf("hlt\n");}
	//print_reg(sim_p);
	if(IS_DEBUG){
		print_f_reg(sim_p);
		print_mem(sim_p);
		printf("dynamic_inst_cnt = %d\n", sim_p->dynamic_inst_cnt);
	}
	return 0;
}


int simulate_inst(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char fmt_binary, unsigned char ft_binary, unsigned char function_binary)
{
	/*
	if(IS_DEBUG){
		printf("operation_binary = %d\n", operation_binary);
		printf("fmt_binary = %d\n", fmt_binary);
		printf("ft_binary = %d\n", ft_binary);
		printf("function_binary = %d\n", function_binary);
	}
	*/

	sim_p->dynamic_inst_cnt++;
	//if(IS_DEBUG){printf("%d\n", sim_p->pc);}
	if(operation_binary == 0 && function_binary == 32) return inst_add(sim_p, inst);

	if(operation_binary == 8) return inst_addi(sim_p, inst);

	if(operation_binary == 0 && function_binary == 36) return inst_and(sim_p, inst);

	if(operation_binary == 4) return inst_beq(sim_p, inst);

	if(operation_binary == 5) return inst_bne(sim_p, inst);

	if(operation_binary == 2) return inst_j(sim_p, inst);

	if(operation_binary == 3) return inst_jal(sim_p, inst);

	if(operation_binary == 0 && function_binary == 8) return inst_jr(sim_p, inst);

	if(operation_binary == 0 && function_binary == 9) return inst_jral(sim_p, inst);

	if(operation_binary == 35) return inst_lw(sim_p, inst);

	if(operation_binary == 0 && function_binary == 39) return inst_nor(sim_p, inst);

	if(operation_binary == 0 && function_binary == 37) return inst_or(sim_p, inst);

	if(operation_binary == 13) return inst_ori(sim_p, inst);

	if(operation_binary == 0 && function_binary == 42) return inst_slt(sim_p, inst);

	if(operation_binary == 10) return inst_slti(sim_p, inst);

	if(operation_binary == 0 && function_binary == 0) return inst_sll(sim_p, inst);

	if(operation_binary == 0 && function_binary == 2) return inst_srl(sim_p, inst);

	if(operation_binary == 43) return inst_sw(sim_p, inst);

	if(operation_binary == 0 && function_binary == 34) return inst_sub(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 8 && ft_binary == 1) return inst_bclt(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 8 && ft_binary == 0) return inst_bclf(sim_p, inst);

	if(operation_binary == 0 && function_binary == 26) return inst_div(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 0) return inst_adds(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 16 &&function_binary == 50) return inst_cs(sim_p, inst, 0);

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 60) return inst_cs(sim_p, inst, 1);

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 62) return inst_cs(sim_p, inst, 2);

	if(operation_binary ==17 && fmt_binary == 16  && function_binary == 2) return inst_muls(sim_p, inst);

	if(operation_binary == 22 && function_binary == 22) return inst_invs(sim_p, inst);

	/*
	 * MIPS say 17, 16, 3 is FDIV
	 * but map this to FINV
	 */
	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 3) return inst_invs(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 1) return inst_subs(sim_p, inst);

	if(operation_binary == 49) return inst_lws(sim_p, inst);

	if(operation_binary == 0 && function_binary == 24) return inst_mult(sim_p, inst);

	if(operation_binary == 57) return inst_sws(sim_p, inst);

	if(operation_binary == 26) return inst_in_(sim_p, inst);

	if(operation_binary == 27) return inst_out(sim_p, inst);

	if(operation_binary == 63 && function_binary == 63) return inst_hlt(sim_p, inst);

	if(IS_DEBUG){
		puts("Not Found");
		printf("operation_binary = %d\n", operation_binary);
		printf("fmt_binary = %d\n", fmt_binary);
		printf("ft_binary = %d\n", ft_binary);
		printf("function_binary = %d\n", function_binary);
		printf("inst_binary = ");
		print_int2bin(inst);
	}
	return 0;
}

void simulate(simulator* sim_p)
{
	instruction inst;
	unsigned char operation_binary;
	unsigned char fmt_binary;
	unsigned char ft_binary;
	unsigned char function_binary;
	int res = 0;
	//print_reg(sim_p);
	sim_p->pc = sim_p->entry_point;
	while(1){
		if(IS_DEBUG) printf("%d\n", sim_p->pc);
		inst = 0;
		inst = load_char(inst, inst2char(sim_p->inst_mem[sim_p->pc], 0), 0);
		inst = load_char(inst, inst2char(sim_p->inst_mem[sim_p->pc], 1), 1);
		inst = load_char(inst, inst2char(sim_p->inst_mem[sim_p->pc], 2), 2);
		inst = load_char(inst, inst2char(sim_p->inst_mem[sim_p->pc], 3), 3);

		operation_binary = get_binary_unsigned(inst, 0, 6);
		fmt_binary = get_binary_unsigned(inst, 6, 11);
		ft_binary = get_binary_unsigned(inst, 11, 16); 
		function_binary = get_binary_unsigned(inst, 26, 32);

		res = simulate_inst(sim_p, inst, operation_binary, fmt_binary, ft_binary, function_binary);
		//if(IS_DEBUG){print_reg(sim_p);}
		//if(IS_DEBUG)printf("simulate_inst returns\n");
		if(res == 0){
			break;
		}else{
			continue;
		}
	}
	printf("dynamic_inst_cnt = %d\n", sim_p->dynamic_inst_cnt);
	// print %v0
	printf("int:%d,float:%.8f\n", sim_p->reg[2], sim_p->f_reg[2]);
}

