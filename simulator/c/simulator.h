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

simulator *init_sim()
{
	simulator *sim = (simulator *)malloc(sizeof(simulator));
	sim->pc = 0;
	sim->dynamic_inst_cnt = 0;
	sim->fpcond = 0;
	sim->reg = (int*)malloc(sizeof(int) * 32);
	sim->f_reg = (float*)malloc(sizeof(float) * 32);
	for(int i = 0; i < 32; i++){
		sim->f_reg[i] = 0.0;
	}
	memset(sim->reg, 0, (sizeof(int) * 32));
	//memset(sim->f_reg, 0, (sizeof(float) * 32));
	//stackpointer = reg[29]
	sim->reg[29] = 1000;
	sim->mem = malloc(1000000);
	return sim;
}

void free_sim(simulator *sim) {
	SAFE_DELETE(sim->reg);
	SAFE_DELETE(sim->f_reg);
	SAFE_DELETE(sim->mem);
	SAFE_DELETE(sim);
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
	sim->entry_point /= 4;
	printf("text_size = %d\n", sim->text_size);
	printf("data_size = %d\n", sim->data_size);
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
	printf("sim->binary_size = %d\n", sim->binary_size);
	printf("sim->text_size = %d\n", sim->text_size);

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
	memset(sim->inst_mem, 0, binary_size);
	//printf("binary_size = %d, inst_cnt = %d\n", binary_size, sim->inst_cnt);
	load_header(sim, buf);
	load_instruction(sim, buf);
	load_data(sim, buf);
	return;
}

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

operands decode_R(inst)
{
	operands ops;
	ops.reg_s_idx = get_binary_unsigned(inst, 6, 11);
	ops.reg_t_idx = get_binary_unsigned(inst, 11, 16);
	ops.reg_d_idx = get_binary_unsigned(inst, 16, 21);
	ops.shamt = get_binary_unsigned(inst, 21, 26);
	return ops;
}

operands decode_I(inst)
{
	operands ops;
	ops.reg_s_idx = get_binary_unsigned(inst, 6, 11);
	ops.reg_t_idx = get_binary_unsigned(inst, 11, 16);
	ops.imm = get_binary_signed(inst, 16, 32);
	return ops;
}

operands decode_J(inst)
{
	operands ops;
	ops.imm = get_binary_signed(inst, 6, 32);
	return ops;
}

operands decode_FR(inst)
{
	operands ops;
	ops.ft_idx = get_binary_signed(inst, 11, 16);
	ops.fs_idx = get_binary_signed(inst, 16, 21);
	ops.fd_idx = get_binary_signed(inst, 21, 26);
	return ops;
}

operands decode_FI(inst)
{
	operands ops;
	ops.ft_idx = get_binary_signed(inst, 11, 16);
	ops.imm = get_binary_signed(inst, 16, 32);
	return ops;
}

int inst_add(simulator* sim_p, instruction inst)
{
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
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->reg[ops.reg_t_idx] = ops.imm + reg_s;
	sim_p->pc++; 
	return 1;
}

int inst_and(simulator* sim_p, instruction inst)
{
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
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	if(reg_s == reg_t){
		sim_p->pc += ops.imm;
	}else{
		sim_p->pc++;
	}
	return 1;
}

int inst_bne(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	if(reg_s != reg_t){
		sim_p->pc += ops.imm;
	}else{
		sim_p->pc++;
	}
	return 1;
}

int inst_j(simulator* sim_p, instruction inst)
{
	operands ops = decode_J(inst);
	sim_p->pc = ops.imm;
	return 1;
}

int inst_jal(simulator* sim_p, instruction inst)
{
	sim_p->reg[31] = (sim_p->pc + 1);
	operands ops = decode_J(inst);
	sim_p->pc = ops.imm;
	return 1;
}

int inst_jr(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->pc = reg_s;
	return 1;
}

int inst_lw(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->reg[ops.reg_t_idx] = sim_p->mem[reg_s + ops.imm];
	sim_p->pc++;
	return 1;
}

int inst_nor(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->reg[ops.reg_d_idx] = ~(reg_s | reg_t);
	sim_p->pc++;
	return 1;
}

int inst_or(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->reg[ops.reg_d_idx] = (reg_s | reg_t);
	sim_p->pc++;
	return 1;
}

int inst_ori(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	int imm = get_binary_signed(inst, 16, 32);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	sim_p->reg[ops.reg_t_idx] = (reg_s | imm);
	sim_p->pc++;
	return 1;
}

int inst_slt(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
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
	operands ops = decode_R(inst);
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->reg[ops.reg_d_idx] = reg_t << ops.shamt;
	sim_p->pc++;
	return 1;
}

int inst_srl(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->reg[ops.reg_d_idx] = reg_t >> ops.shamt;
	sim_p->pc++;
	return 1;

}

int inst_sw(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->mem[reg_s + ops.imm] = reg_t; 
	sim_p->pc++;
	return 1;
}

int inst_sub(simulator* sim_p, instruction inst)
{
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
	operands ops = decode_FI(inst);
	if(sim_p->fpcond){
		sim_p->pc += ops.imm;
	}else{
		sim_p->pc++;
	}
	return 1;
}
int inst_bclf(simulator* sim_p, instruction inst)
{
	operands ops = decode_FI(inst);
	if(!sim_p->fpcond){
		sim_p->pc += ops.imm;
	}else{
		sim_p->pc ++;
	}
	return 1;
}

int inst_div(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	int reg_s = sim_p->reg[ops.reg_s_idx];
	int reg_t = sim_p->reg[ops.reg_t_idx];
	sim_p->Lo = reg_s / reg_t;
	sim_p->Hi = reg_s % reg_t;
	sim_p->pc++;
	return 1;
}

int inst_adds(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	float ft = sim_p->f_reg[ops.ft_idx];
	float fs = sim_p->f_reg[ops.fs_idx];
	float fd = ft + fs;
	sim_p->f_reg[ops.fd_idx] = fd;
	sim_p->pc++;
	return 1;
}

int inst_cs(simulator* sim_p, instruction inst, int option)
{
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
	if(option == 0 && fs == ft){
		sim_p->fpcond = 1;
	}else if(option == 1 && fs < ft){
		sim_p->fpcond = 1;
	}else if(option == 2 && fs <= ft){
		sim_p->fpcond = 1;
	}else{
		sim_p->fpcond = 0;
	}
	sim_p->pc++;
	return 1;
}

int inst_muls(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	float ft = sim_p->f_reg[ops.ft_idx];
	float fs = sim_p->f_reg[ops.fs_idx];
	float fd = ft * fs;
	sim_p->f_reg[ops.fd_idx] = fd;
	sim_p->pc++;
	return 1;
}

int inst_invs(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	float ft = sim_p->f_reg[ops.ft_idx];
	float fs = sim_p->f_reg[ops.fs_idx];
	float fd = ft / fs;
	sim_p->f_reg[ops.fd_idx] = fd;
	sim_p->pc++;
	return 1;
}

int inst_subs(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	float ft = sim_p->f_reg[ops.ft_idx];
	float fs = sim_p->f_reg[ops.fs_idx];
	float fd = ft - fs;
	sim_p->f_reg[ops.fd_idx] = fd;
	sim_p->pc++;
	return 1;
}

int inst_lws(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	float ft = int2float(sim_p->mem[sim_p->reg[ops.reg_s_idx] + ops.imm]);
	sim_p->f_reg[ops.reg_t_idx] = ft;
	sim_p->pc++;
	return 1;
}

int inst_mult(simulator* sim_p, instruction inst)
{
	//not used??
	return 1;
}

int inst_sws(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	float ft = sim_p->f_reg[ops.reg_t_idx];
	sim_p->mem[sim_p->reg[ops.reg_s_idx] + ops.imm] = float2int(ft);
	sim_p->pc++;
	return 1;
}


int inst_hlt(simulator* sim_p, instruction inst)
{
	//print_reg(sim_p);
	if(IS_DEBUG){
		print_f_reg(sim_p);
		printf("dynamic_inst_cnt = %d\n", sim_p->dynamic_inst_cnt);
	}
	return 0;
}


int simulate_inst(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char fmt_binary, unsigned char ft_binary, unsigned char function_binary)
{
	sim_p->dynamic_inst_cnt++;
	//if(IS_DEBUG){printf("%d\n", sim_p->pc);}
	if(operation_binary == 0 && function_binary == 32){ 
		if(IS_DEBUG){puts("add");}
		return inst_add(sim_p, inst);
	}

	if(operation_binary == 8){ 
		if(IS_DEBUG){puts("addi");}
		return inst_addi(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 36){ 
		if(IS_DEBUG){puts("and_");}
		return inst_and(sim_p, inst);
	}

	if(operation_binary == 4){ 
		if(IS_DEBUG){puts("beq");}
		return inst_beq(sim_p, inst);
	}

	if(operation_binary == 5){ 
		if(IS_DEBUG){puts("bne");}
		return inst_bne(sim_p, inst);
	}

	if(operation_binary == 2){ 
		if(IS_DEBUG){puts("j");}
		return inst_j(sim_p, inst);
	}

	if(operation_binary == 3){ 
		if(IS_DEBUG){puts("jal");}
		return inst_jal(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 8){ 
		if(IS_DEBUG){puts("jr");}
		return inst_jr(sim_p, inst);
	}

	if(operation_binary == 35){ 
		if(IS_DEBUG){puts("lw");}
		return inst_lw(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 39){ 
		if(IS_DEBUG){puts("nor");}
		return inst_nor(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 37){ 
		if(IS_DEBUG){puts("or_");}
		return inst_or(sim_p, inst);
	}

	if(operation_binary == 13){ 
		if(IS_DEBUG){puts("ori");}
		return inst_ori(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 42){ 
		if(IS_DEBUG){puts("slt");}
		return inst_slt(sim_p, inst);
	}

	if(operation_binary == 10){ 
		if(IS_DEBUG){puts("slti");}
		return inst_slti(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 0){ 
		if(IS_DEBUG){puts("sll");}
		return inst_sll(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 2){ 
		if(IS_DEBUG){puts("srl");}
		return inst_srl(sim_p, inst);
	}

	if(operation_binary == 43){ 
		if(IS_DEBUG){puts("sw");}
		return inst_sw(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 34){ 
		if(IS_DEBUG){puts("sub");}
		return inst_sub(sim_p, inst);
	}

	if(operation_binary == 17 && fmt_binary == 8 && ft_binary == 1){ 
		if(IS_DEBUG){puts("bclt");}
		return inst_bclt(sim_p, inst);
	}

	if(operation_binary == 17 && fmt_binary == 8 && ft_binary == 0){ 
		if(IS_DEBUG){puts("bclf");}
		return inst_bclf(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 26){ 
		if(IS_DEBUG){puts("div");}
		return inst_div(sim_p, inst);
	}

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 0){ 
		if(IS_DEBUG){puts("add.s");}
		return inst_adds(sim_p, inst);
	}

	if(operation_binary == 17 && fmt_binary == 17 &&function_binary == 50){ 
		if(IS_DEBUG){puts("c.eq.s");}
		return inst_cs(sim_p, inst, 0);
	}

	if(operation_binary == 17 && fmt_binary == 17 && function_binary == 60){ 
		if(IS_DEBUG){puts("c.lt.s");}
		return inst_cs(sim_p, inst, 1);
	}

	if(operation_binary == 17 && fmt_binary == 17 && function_binary == 62){ 
		if(IS_DEBUG){puts("c.le.s");}
		return inst_cs(sim_p, inst, 2);
	}

	if(operation_binary ==17 && fmt_binary == 16  && function_binary == 2){ 
		if(IS_DEBUG){puts("mul.s");}
		return inst_muls(sim_p, inst);
	}

	if(operation_binary == 22 && function_binary == 22){ 
		if(IS_DEBUG){puts("inv.s");}
		//!!!!!!!!!inv is not exits in MIPS
		return inst_invs(sim_p, inst);
	} 

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 1){ 
		if(IS_DEBUG){puts("sub.s");}
		return inst_subs(sim_p, inst);
	}

	if(operation_binary == 49){ 
		if(IS_DEBUG){puts("lw.s");}
		return inst_lws(sim_p, inst);
	}

	if(operation_binary == 0 && function_binary == 24){ 
		if(IS_DEBUG){puts("mult");}
		return inst_mult(sim_p, inst);
	}

	if(operation_binary == 57){ 
		if(IS_DEBUG){puts("sw.s");}
		return inst_sws(sim_p, inst);
	}

	if(operation_binary == 63 && function_binary == 63){ 
		if(IS_DEBUG){puts("hlt");}
		return inst_hlt(sim_p, inst);
	}
	puts("Not Found");
	printf("operation_binary = %d\n", operation_binary);
	printf("fmt_binary = %d\n", fmt_binary);
	printf("fmt_binary = %d\n", ft_binary);
	printf("function_binary = %d\n", function_binary);

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
		//printf("%d : ", sim_p->pc);
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
		if(res == 0){
			break;
		}else{
			continue;
		}
	}

	// print %v0
	printf("%d\n", sim_p->reg[2]);
}
