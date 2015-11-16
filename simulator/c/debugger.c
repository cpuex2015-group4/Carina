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

/*
 * Debugger Global Variable
 */
int is_running = 0; // if True, run unless pc=BreakPoint
int breakpoint[10000000] = {}; // breakpoint[pc] is 1 if pc==breakpoint else 0

int simulate_inst_debug(simulator* sim_p, instruction inst, unsigned char operation_binary, unsigned char fmt_binary, unsigned char ft_binary, unsigned char function_binary){
	char input[100];
	printf("%s", PROMPT);
	while(1){
		scanf("%[^\n]", input);
		if(strcmp(input, "next") == 0){
			break;
		}

		if(strcmp("break", input) < 0 && strcmp(input, "break~") < 0){
			printf("break\n");	
			getchar();
			break;
		}

		if(strcmp(input, "run") == 0){
			break;
		}

		printf("invalid command\n");
	}
	return simulate_inst(sim_p, inst, operation_binary, fmt_binary, ft_binary, function_binary);
}

