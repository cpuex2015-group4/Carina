#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char **argv) {
	float f = atof(argv[1]);
	printf("%.8f\n", tan(f));
	return 0;
}
