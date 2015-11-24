#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <math.h>

int main(int argc, char **argv) {
	if(!strncmp(argv[1], "sin", 3)) {
		fprintf(stderr, "Not Implemented\n");
	} else if(!strncmp(argv[1], "cos", 3)) {
		fprintf(stderr, "Not Implemented\n");
	} else if(!strncmp(argv[1], "tan", 3)) {
		fprintf(stderr, "Not Implemented\n");
	} else if(!strncmp(argv[1], "atan", 4)) {
		fprintf(stderr, "Not Implemented\n");
	} else if(!strncmp(argv[1], "sqrt", 4)) {
		fprintf(stderr, "Not Implemented\n");
	}
	return 0;
}
