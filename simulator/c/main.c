/*
 * USAGE
 * -------------------------
 * /path/to/this/dir/csim -f [objectfile] 
 *
 * OPTION
 * -------------------------
 *  -f [objectfile] Essential
 *  -c Instruction Count 
 *  -t Test (when to make output only result(="int:[int_res],float:[float_res]"))
 *  -d Debug Option
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include "./simulator.h"
#define USE_FPU_SIM 0

int IS_DEBUG = 0;
int INST_CNT = 0;
unsigned long MEM_SIZE = 100000000000LL;

int main(int argc, char* argv[])
{
	FILE* fp_binary;
	int result;
	while((result=getopt(argc,argv,"cdf:"))!=-1){
		switch(result){
			/* 
			 * Option that does not need arg
			 */
			case 'd':
				fprintf(stdout, "DEBUG ON\n");
				IS_DEBUG = 1;
				break;

			case 'c':
				fprintf(stdout, "INST CNT ON\n");
				INST_CNT = 1;
				break;
				
			/*
			 * Option that needs arg
			 */
			case 'f':
				if ((fp_binary = fopen(optarg, "rb")) == NULL) {
					printf("file open error!!\n");
					exit(EXIT_FAILURE);
				}
				if(IS_DEBUG)fprintf(stdout,"Object File : %s\n", optarg);
				break;
			case ':':
				fprintf(stdout,"%c needs value\n",result);
				break;
			case '?':
				fprintf(stdout,"unknown\n");
				break;
		}
	}

	simulator *sim = init_sim();
	load_binary(sim, fp_binary);
	simulate(sim);
	fclose(fp_binary);
	free_sim(sim);
	return 0;
}
