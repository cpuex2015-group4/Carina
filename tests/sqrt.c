/*
sqrt 2.0
*/

#include <stdio.h>

float fastInvSqrt(float x) {
	if(x == 0) {
		return 0;
	}
	
	const unsigned int magic = 0x5f3759df;
	const float threehalf = 1.5f;

	unsigned int y = magic - (*((unsigned int*)&x) >> 1);
	float z = *((float*)&y);

	z *= (threehalf - x*z*z*0.5f);
	z *= (threehalf - x*z*z*0.5f);
	z *= (threehalf - x*z*z*0.5f);
	return x*z;
}

int main() {
	float res = fastInvSqrt(2.0);
	printf("%.8f\n", res);
	return 0;
}
