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

// to <= from(up downto down);
union hoge{
  float    f;
	uint32_t i;
};

uint32_t fromdownto(uint32_t from, int up, int down){
  uint32_t to = 0;
	int i;

	for(i = up; i > down-1; i--){
	  to = (to << 1) | ((from >> i) & (uint32_t)1);
	}

	return to;
}

// to(up downto down) <= from;
uint32_t todownto(uint32_t from, uint32_t to, int up, int down){
  uint32_t mask = 0; // 代入すべき箇所を0で初期化
  int i;
	for(i = 0; i < mask; i++){
	  mask = mask | ((uint32_t)1 << i);
	}
	for(i = up+1; i < 64; i++){
	  mask = mask | ((uint32_t)1 << i);
	}
	to = to & mask;
  for(i = down; i < up+1; i++){
	  to = to | ((from & (uint32_t)1) << i);
		from >> 1;
	}
	return to;
}

void printbit(char *name, uint32_t f, int up, int down){
  int i,j;
  printf("%s =",name);
	j = down;

  for(i = 0; down < up+1; down++){
	  if(up == 31 && j == 0){
      if(i == 0 || i == 1 || i == 9) printf(" ");
			i++;
		}
	  printf("%d", (int)((f & ((uint32_t)1 << (up-down))) >> (up-down)));
	}
	puts("");
}	 

int main(int argc, char *argv[]){
  union hoge input;
	union hoge answer;
	union hoge a0;
	union hoge x0; // initial number
	union hoge x1; // to derive initial number
	union hoge x2; // to derive initial number
	union hoge constant;
	union hoge gradient;
	union hoge one;
	uint32_t key;

	uint32_t a1; // 13bit
	uint32_t gr; // 9bit gradient(+hidden bit)
	union hoge out;

  input.f  = 1.2734;
	one.f    = 1.0;
	answer.f = one.f / input.f;

//  for(key = 0; key < 0x400; key++){
//  x1.i = todownto(key, input.i, 22, 13);
//	x2.i = todownto(key, input.i, 22, 13) + 0x2000;
  a0.i = fromdownto(input.i, 31, 13) << 13;
	a1 = fromdownto(input.i, 12,  0);

	x1.f = one.f / a0.f;
	x2.i = a0.i + 0x2000;
	x2.f = one.f / x2.f;
	x0.f = (x1.f + x2.f)/2;

  constant.f = 2*x0.f - a0.f * x0.f * x0.f;
	gradient.f = x0.f * x0.f;

	gr = fromdownto(gradient.i, 22, 14) + 0x200;
	out.i = constant.i - ((a1 * gr) >> 10);
    
//	}
  printbit("input   ", input.i, 31, 0);
  printbit("a1      ", a1, 31, 0);
  printbit("constant", constant.i, 31, 0);
	printbit("answer  ", answer.i, 31, 0);
	printbit("output  ", out.i, 31, 0);
  
	return 0;
}
