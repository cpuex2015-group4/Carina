#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./const.h"
#include "./utils.h"
#include "./simulator.h"

int main(int argc, char* argvs[])
{
	char* filename_binary = argvs[1];
	FILE* fp_binary;
	if ((fp_binary = fopen(filename_binary, "rb")) == NULL) {
		printf("file open error!!\n");
		exit(EXIT_FAILURE);
	}

	simulator *sim = init_sim();
	load_binary(sim, fp_binary);
	simulate(sim);
	fclose(fp_binary);
	free_sim(sim);
	return 0;
}
