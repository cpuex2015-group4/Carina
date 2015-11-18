#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./utils.h"
#include "./simulator.h"
#include "./debugger.h"

/*
 *
 * 88        88           88  88           
 * 88        88           88  88           
 * 88        88           88  88           
 * 88aaaaaaaa88   ,adPPYb,88  88,dPPYba,   
 * 88""""""""88  a8"    `Y88  88P'    "8a  
 * 88        88  8b       88  88       d8  
 * 88        88  "8a,   ,d88  88b,   ,a8"  
 * 88        88   `"8bbdP"Y8  8Y"Ybbd8"'   
 * ============================================================
 *
 * Hatsukoi DeBugger
 *
 * Command
 * ------------------------------------------------------------------
 * - next:
 *   run the next instruction
 *
 * - break n:
 *   set BreakPoint to the instruction whose PC is 'n'
 *
 * - run:
 *   run the program until reaches a BreakPoint
 *
 */

char* PROMPT = "Hdb > ";

void main_debugger(void)
{
	fprintf(stderr, "88        88           88  88          \n"); 
	fprintf(stderr, "88        88           88  88          \n"); 
	fprintf(stderr, "88        88           88  88          \n"); 
	fprintf(stderr, "88aaaaaaaa88   ,adPPYb,88  88,dPPYba,  \n"); 
	fprintf(stderr, "88\"\"\"\"\"\"\"\"88  a8\"    `Y88  88P'    \"8a \n"); 
	fprintf(stderr, "88        88  8b       88  88       d8 \n"); 
	fprintf(stderr, "88        88  \"8a,   ,d88  88b,   ,a8\" \n"); 
	fprintf(stderr, "88        88   `\"8bbdP\"Y8  8Y\"Ybbd8\"'  \n"); 
	fprintf(stderr, "=======================================\n"); 
	fprintf(stderr, "\n");
}

extern int simulate_inst(simulator* , instruction, unsigned char, unsigned char, unsigned char, unsigned char);

int get_break_point(char* input)
{
	/*
	 * Args:
	 *	input ("return hoge")
	 * Returns:
	 *	pc
	 */
	int i;
	for(i = 0; i < 100; i++){
		if(input[i] == '\0')break;
	}
	//i is the length of input
	
	char* pc_buf = malloc(i - 6);
	int j;
	for(j = 0; j < (i - 6); j++){
		pc_buf[j] = input[6+j];
	}
	int pc = atoi(pc_buf); 
	free(pc_buf);
	return pc;
}


/*
 * reference from simlator.c
 */
extern operands decode_R(instruction);

extern operands decode_I(instruction);

extern operands decode_J(instruction);

extern operands decode_FR(instruction);

extern operands decode_FI(instruction);

int print_inst_add(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_addi(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_and(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_andi(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_beq(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_bne(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_j(simulator* sim_p, instruction inst)
{
	operands ops = decode_J(inst);
	return 1;
}

int print_inst_jal(simulator* sim_p, instruction inst)
{
	sim_p->reg[31] = ((sim_p->pc + 1));
	operands ops = decode_J(inst);
	sim_p->pc = ops.imm;
	return 1;
}

int print_inst_jr(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_jral(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_lw(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_nor(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_or(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_ori(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_slt(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_slti(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_sll(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_srl(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_sw(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_sub(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_bclt(simulator* sim_p, instruction inst)
{
	operands ops = decode_FI(inst);
	return 1;
}
int print_inst_bclf(simulator* sim_p, instruction inst)
{
	operands ops = decode_FI(inst);
	return 1;
}

int print_inst_div(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

extern uint32_t fadd(uint32_t, uint32_t);

int print_inst_adds(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	return 1;
}

int print_inst_cseq(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	return 1;
}

int print_inst_cslt(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	return 1;
}

int print_inst_csle(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	return 1;
}

extern uint32_t fmul(uint32_t, uint32_t);

typedef union myfloat_{
	uint32_t muint;
	float mfloat;
}myfloat;

int print_inst_muls(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	return 1;
}

int print_inst_invs(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	return 1;
}

int print_inst_divs(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	return 1;
}

int print_inst_subs(simulator* sim_p, instruction inst)
{
	operands ops = decode_FR(inst);
	return 1;
}

int print_inst_lws(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_mult(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_sws(simulator* sim_p, instruction inst)
{
	operands ops = decode_I(inst);
	return 1;
}

int print_inst_in_(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_out(simulator* sim_p, instruction inst)
{
	operands ops = decode_R(inst);
	return 1;
}

int print_inst_hlt(simulator* sim_p, instruction inst)
{
	return 0;
}

int print_inst(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char fmt_binary, unsigned char ft_binary, unsigned char function_binary)
{
	/*
	 *
	 */
	if(operation_binary == 0 && function_binary == 32) return print_inst_add(sim_p, inst);

	if(operation_binary == 8) return print_inst_addi(sim_p, inst);

	if(operation_binary == 0 && function_binary == 36) return print_inst_and(sim_p, inst);

	if(operation_binary == 12) return print_inst_andi(sim_p, inst);

	if(operation_binary == 4) return print_inst_beq(sim_p, inst);

	if(operation_binary == 5) return print_inst_bne(sim_p, inst);

	if(operation_binary == 2) return print_inst_j(sim_p, inst);

	if(operation_binary == 3) return print_inst_jal(sim_p, inst);

	if(operation_binary == 0 && function_binary == 8) return print_inst_jr(sim_p, inst);

	if(operation_binary == 0 && function_binary == 9) return print_inst_jral(sim_p, inst);

	if(operation_binary == 35) return print_inst_lw(sim_p, inst);

	if(operation_binary == 0 && function_binary == 39) return print_inst_nor(sim_p, inst);

	if(operation_binary == 0 && function_binary == 37) return print_inst_or(sim_p, inst);

	if(operation_binary == 13) return print_inst_ori(sim_p, inst);

	if(operation_binary == 0 && function_binary == 42) return print_inst_slt(sim_p, inst);

	if(operation_binary == 10) return print_inst_slti(sim_p, inst);

	if(operation_binary == 0 && function_binary == 0) return print_inst_sll(sim_p, inst);

	if(operation_binary == 0 && function_binary == 2) return print_inst_srl(sim_p, inst);

	if(operation_binary == 43) return print_inst_sw(sim_p, inst);

	if(operation_binary == 0 && function_binary == 34) return print_inst_sub(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 8 && ft_binary == 1) return print_inst_bclt(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 8 && ft_binary == 0) return print_inst_bclf(sim_p, inst);

	if(operation_binary == 0 && function_binary == 26) return print_inst_div(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 0) return print_inst_adds(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 16 &&function_binary == 50) return print_inst_cseq(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 60) return print_inst_cslt(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 62) return print_inst_csle(sim_p, inst);

	if(operation_binary ==17 && fmt_binary == 16  && function_binary == 2) return print_inst_muls(sim_p, inst);

	//if(operation_binary == 22 && function_binary == 22) return print_inst_invs(sim_p, inst);
	/*
	 * MIPS say 17, 16, 3 is FDIV
	 * but map this to FINV
	 */
	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 3) return print_inst_invs(sim_p, inst);

	if(operation_binary == 17 && fmt_binary == 16 && function_binary == 1) return print_inst_subs(sim_p, inst);

	if(operation_binary == 49) return print_inst_lws(sim_p, inst);

	if(operation_binary == 0 && function_binary == 24) return print_inst_mult(sim_p, inst);

	if(operation_binary == 57) return print_inst_sws(sim_p, inst);

	if(operation_binary == 26) return print_inst_in_(sim_p, inst);

	if(operation_binary == 27) return print_inst_out(sim_p, inst);

	if(operation_binary == 63 && function_binary == 63) return print_inst_hlt(sim_p, inst);

}
/*
 * Debugger Global Variable
 */
int is_running;
int breakpoint_cnt = 0; // if True, run unless pc=BreakPoint
int breakpoint[10000000] = {}; // breakpoint[pc] is 1 if pc==breakpoint else 0

int simulate_inst_debug(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char fmt_binary, unsigned char ft_binary, unsigned char function_binary)
{
	char input[100];
	int pc;
	while(1){

		if(is_running && !breakpoint[sim_p->pc])break; //if not breakpoint && some breakpoint is set, run continuously

		if(breakpoint[sim_p->pc]){
			breakpoint[sim_p->pc] = 0;
			breakpoint_cnt--;
			is_running = 0;
		}

		fprintf(stderr, "PC = %lu\n", sim_p->pc);
		fprintf(stderr, "%s", PROMPT);

		scanf("%[^\n]", input);
		getchar(); //dummy to throw \n away

		if(strcmp(input, "next") == 0){
			break;
		}

		if(strcmp(input, "run") == 0){
			is_running = 1;
			break;
		}

		if(strcmp("break", input) < 0 && strcmp(input, "break~") < 0){ //command == break && exists argument
			pc = get_break_point(input);
			if(breakpoint[pc]){
				break;
			}
			breakpoint[pc] = 1;
			breakpoint_cnt++;
			break;
		}

		if(strcmp("break", input) == 0){
			fprintf(stderr, "break nees a argument\n");
			continue;
		}

		fprintf(stderr, "invalid command\n");
		continue;
	}
	return simulate_inst(sim_p, inst, operation_binary, fmt_binary, ft_binary, function_binary);
}

