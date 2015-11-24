#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

int main(int argc, char **argv) {
	float f = atof(argv[2]);
	if(!strncmp(argv[1], "sin", 3)) {
		printf("%.8f\n", sin(f));
	} else if(!strncmp(argv[1], "cos", 3)) {
		printf("%.8f\n", cos(f));
	} else if(!strncmp(argv[1], "tan", 3)) {
		printf("%.8f\n", tan(f));
	} else if(!strncmp(argv[1], "atan", 4)) {
		printf("%.8f\n", atan(f));
	} else if(!strncmp(argv[1], "sqrt", 4)) {
		printf("%.8f\n", sqrt(f));
	}
	return 0;
}
