#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./utils.h"
#include "./simulator.h"

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

char* PROMPT = "Hatsukoi > ";

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
 * Debugger Global Variable
 */
int is_running;
int breakpoint_cnt = 0; // if True, run unless pc=BreakPoint
int breakpoint[10000000] = {}; // breakpoint[pc] is 1 if pc==breakpoint else 0

int simulate_inst_debug(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char fmt_binary, unsigned char ft_binary, unsigned char function_binary){
	char input[100];
	int pc;
	while(1){

		if(is_running && !breakpoint[sim_p->pc])break; //if not breakpoint && some breakpoint is set, run continuously

		if(breakpoint[sim_p->pc]){
			breakpoint[sim_p->pc] = 0;
			breakpoint_cnt--;
			is_running = 0;
		}

		printf("PC = %d\n", sim_p->pc);
		printf("%s", PROMPT);

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
			printf("break nees a argument\n");
			continue;
		}

		printf("invalid command\n");
		continue;
	}
	return simulate_inst(sim_p, inst, operation_binary, fmt_binary, ft_binary, function_binary);
}

