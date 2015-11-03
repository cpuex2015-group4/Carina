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
  uint64_t f;
	uint64_t b;
  uint64_t a; // a0(10bit)
	uint64_t i; // initial
	uint64_t c;
	uint64_t g; // gradient
	uint64_t ans;
	uint64_t o;

	int j;

//  for(a = 512; a < 1024; a++){
  f = 10658464;
	ans = 70368744177664 / f;
	a = 650;
	b = 8864;
    // calcrate initial number x0(24bit)
    i = (((uint64_t)1 << 32)/a + (((uint64_t)1 << 32)/(a+(uint64_t)1)));
		if((i & (uint64_t)1) == 1){
		  i = (i >> 1) + (uint64_t)1;
		}else{
		  i = (i >> 1);
		}
		// calcrate constant c(24bit)
		c = 2*i - ((a*i*i) >> 32);

		// calcrate gradient g(8bit)
		g = (i*i) >> 40;
	o = c + ((b*g) >> 6);

  printf("ans =");
  for(j = 0; j < 24 ; j++){
		if(j % 5 == 0) printf(" ");
	  printf("%d", (int)((ans & ((uint64_t)1 << (23-j))) >> (23-j)));
	}
	printf("\no   =");
	for(j = 0; j < 24; j++){
		if(j % 5 == 0) printf(" ");
	  printf("%d", (int)((o   & ((uint64_t)1 << (23-j))) >> (23-j)));
	}
  
	puts("");
//	}


	return 0;
}
