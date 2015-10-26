#include <stdio.h>
#include <stdint.h>

// A = 1 X X X X X X X X X | X X X X X X X X X X X X X X
//    [      A0(key)      ] [        A1(variable)       ]
// FINVMAN(A) = (2*x0 - A0*x0^2/2^(23+k)) - A1*x0^2/2^46
//             [        constant         ]    [ liner  ]
//
// output file : finv_table.coe
// format :
// MEMORY_INITIALIZATION_RADIX=2;
// MEMORY_INITIALIZATION_VECTOR=
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX,
// ...
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;

int main(int argc, char *argv[]){
	uint64_t a; // a0(10bit)
	uint64_t i; // initial
	uint64_t c;
	uint64_t g; // gradient

	int j;

	printf("MEMORY_INITIALIZATION_RADIX=2;\nMEMORY_INITIALIZATION_VECTOR=\n");
	for(a = 512; a < 1024; a++){
		// calcrate initial number x0(24bit)
		i = (((uint64_t)1 << 32)/a + (((uint64_t)1 << 32)/(a+1)));
		if(i % 2 == 1){
			i = i / 2 + 1;
		}else{
			i = i / 2;
		}
		// calcrate constant c(24bit)
		c = 2*i - ((((a*i) >> 9)*i) >> 23);

		// calcrate gradient g(8bit)
		g = (i*i) >> 40;

		for(j = 0; j < 24; j++){
			printf("%d", (int)((c & ((uint64_t)1 << (23-j))) >> (23-j)));
		}
		for(j = 0; j < 8; j++){
			printf("%d", (int)((g & ((uint64_t)1 << (7-j))) >> (7-j)));
		}
		if(a == 1023){
			puts(";");
		}else{
			puts(",");
		}
	}


	return 0;
}
