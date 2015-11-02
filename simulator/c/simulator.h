
typedef unsigned int instruction;

typedef struct simulator_{
	int pc;
	int* reg;
  int fpcond;
  int Hi;
  int Lo; 
	int inst_cnt;
	instruction* inst_mem;
	int* mem;
	unsigned int data_size;
	unsigned int text_size;
	unsigned int entry_point;
}simulator;

simulator *init_sim()
{
	simulator *sim = (simulator *)malloc(sizeof(simulator));
	sim->pc = 0;
  sim->fpcond = 0;
	sim->reg = (int*)malloc(sizeof(int) * 32);
	memset(sim->reg, 0, (sizeof(int) * 32));
	//stackpointer = reg[29]
	sim->reg[29] = 1000;
	sim->mem = malloc(1000000);
	return sim;
}

void free_sim(simulator *sim) {
	SAFE_DELETE(sim->reg);
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


void load_instruction(simulator* sim, FILE* fp)
{
	unsigned char buf[1000000];
	int binary_size;
	binary_size = fread(buf, sizeof(unsigned char), 1000000, fp);
	sim->inst_mem = malloc(sizeof(unsigned char) * binary_size);
	memset(sim->inst_mem, 0, binary_size);
	sim->inst_cnt = (binary_size - 16) / 4;
	//printf("binary_size = %d, inst_cnt = %d\n", binary_size, sim->inst_cnt);
	int i;
	int OFFSET = 16;

	sim->entry_point = load_char(sim->entry_point, buf[12], 0);
	sim->entry_point = load_char(sim->entry_point, buf[13], 1);
	sim->entry_point = load_char(sim->entry_point, buf[14], 2);
	sim->entry_point = load_char(sim->entry_point, buf[15], 3);
	sim->entry_point /= 4;
	//printf("entry_point = %d\n", sim->entry_point);

	for(i = 0; i * 4 + OFFSET < binary_size; i++){
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 0 + OFFSET], 0);
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 1 + OFFSET], 1);
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 2 + OFFSET], 2);
		(sim->inst_mem)[i] = load_char(sim->inst_mem[i], buf[i * 4 + 3 + OFFSET], 3);
	}

  for(i=0; i < sim->inst_cnt; i++){
		if(i % 4 == 0){
//			puts("");
		}
		//printf("%02X ", inst2char(sim->inst_mem[i], 0)&0xff);
		//printf("%02X ", inst2char(sim->inst_mem[i], 1)&0xff);
		//printf("%02X ", inst2char(sim->inst_mem[i], 2)&0xff);
		//printf("%02X ", inst2char(sim->inst_mem[i], 3)&0xff);
  }
	//printf("\n");
	//printf("instruction loaded\n");
	return;
}

typedef struct operands_{
  unsigned int reg_s_idx;
  unsigned int reg_t_idx;
  unsigned int reg_d_idx;
  int shamt;
  int imm;
  int adress;
  unsigned int ft;
  unsigned int fs;
  unsigned int fd;
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
  ops.ft = get_binary_signed(inst, 11, 16);
  ops.fs = get_binary_signed(inst, 16, 21);
  ops.fd = get_binary_signed(inst, 21, 26);
  return ops;
}

operands decode_FI(inst)
{
  operands ops;
  ops.ft = get_binary_signed(inst, 11, 16);
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
    sim_p->pc ++;
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
  return 1;
}

int inst_cs(simulator* sim_p, instruction inst, int option)
{
  return 1;
}

int inst_muls(simulator* sim_p, instruction inst)
{
  return 1;
}

int inst_invs(simulator* sim_p, instruction inst)
{
  return 1;
}

int inst_subs(simulator* sim_p, instruction inst)
{
  return 1;
}

int inst_lws(simulator* sim_p, instruction inst)
{
  return 1;
}

int inst_mult(simulator* sim_p, instruction inst)
{
  return 1;
}

int inst_sws(simulator* sim_p, instruction inst)
{
  return 1;
}


int inst_hlt(simulator* sim_p, instruction inst)
{
	//print_reg(sim_p);
	return 0;
}


int simulate_inst(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char fmt_binary, unsigned char ft_binary, unsigned char function_binary)
{
  if(IS_DEBUG){printf("%d\n", sim_p->pc);}
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
 
  if(operation_binary == 47){ 
    if(IS_DEBUG){puts("sw.s");}
		return inst_sws(sim_p, inst);
  }
 
  if(operation_binary == 63 && function_binary == 63){ 
    if(IS_DEBUG){puts("hlt");}
		return inst_hlt(sim_p, inst);
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
    if(IS_DEBUG){print_reg(sim_p);}
		if(res == 0){
			break;
		}else{
			continue;
		}
	}

	// print %v0
	printf("%d\n", sim_p->reg[2]);
}
