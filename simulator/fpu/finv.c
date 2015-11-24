#include <stdio.h>
#include <stdint.h>
#include "fpu.h"

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
 

uint32_t finv(uint32_t f) {
	union hoge input;
	union hoge a0;
	union hoge x0; // initial number
	union hoge x1; // to derive initial number
	union hoge x2; // to derive initial number
	union hoge constant;
	union hoge gradient;
	union hoge one;

	uint32_t a1; // 13bit
	uint32_t gr; // 9bit gradient(+hidden bit)
	union hoge out;

	input.i  = f;   // input 
	one.f    = 1.0;

	a0.i = fromdownto(input.i, 31, 13) << 13;
	a1 = fromdownto(input.i, 12,  0);

	x1.f = one.f / a0.f;
	x2.i = a0.i + ((uint32_t)1 << 13);
	x2.f = one.f / x2.f;
	x0.f = (x1.f + x2.f)/2;

	constant.f = 2*x0.f - a0.f * x0.f * x0.f;
	gradient.f = x0.f * x0.f;

	gr = fromdownto(gradient.i, 22, 14) + ((uint32_t)1 << 9);
	out.i = constant.i - ((a1 * gr) >> 10);

	return out.i;
}
