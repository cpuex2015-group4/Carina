#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>

typedef union myfloat_{
	uint32_t muint;
	float mfloat;
} myfloat;

void print_int2bin(uint32_t n)
{
	char buf[32];
	int i;
	for(i = 0; i < 32; i++){
		if(n % 2 == 0){
			buf[i] = '0';
		}else{
			buf[i] = '1';
		}
		n = n >> 1;
	}
	for(i = 0; i < 32; i++){
		printf("%c", buf[31 - i]);
	}
	puts("");
	return;
}

uint32_t get_binary_unsigned(uint32_t n, int start, int end)
{
	//printf("inst_int = %d\n", inst.inst_int);
	int len = end - start;
	//printf("%int", inst.inst_int);
	n = n << start;
	n = n >> (32 - len);
	return n;
}

uint32_t get_fraction(myfloat mf)
{
	return get_binary_unsigned(mf.muint, 9, 32);
}

uint32_t get_exponent(myfloat mf)
{
	return get_binary_unsigned(mf.muint, 1, 9);
}

uint32_t get_sign(myfloat mf)
{
	return get_binary_unsigned(mf.muint, 0, 1);
}

uint32_t set_bit(uint32_t ui, int idx)
{
	return ui | (uint32_t)pow(2, idx);
}

uint32_t unset_bit(uint32_t ui, int idx)
{
	return ui & (~(uint32_t)pow(2, idx));
}

int get_binary_signed(int n, int start, int end)
{
	//printf("inst_int = %d\n", inst.inst_int);
	int len = end - start;
	//printf("%int", inst.inst_int);
	n = n << start;
	n = n >> (32 - len);
	return n;
}


uint32_t get_msb1_idx(uint32_t ui)
{
	int i;
	uint32_t tmp = (int)pow(2, 31);
	if (ui == 0)
		return -1;
	for(i = 0; i < 32; i++){
		if(ui == (ui | tmp)){
			return i;
		};
		ui = ui << 1;
	}
	return -1;
}


uint32_t step4(uint32_t tmp, int* is_underflow)
{
	int msb1_idx = get_msb1_idx(tmp);
	if (msb1_idx == 6){
		*is_underflow = 1;
	}else{
		*is_underflow = 0;
	}
	return get_binary_unsigned(tmp, msb1_idx + 1, msb1_idx + 24);
}


uint32_t bit_round(uint32_t n)
{
	uint32_t tmp = 0;
	int i;
	for(i = 0; i < 32; i++){
		if(n % 2 == 0){
			tmp = unset_bit(tmp, 31 - i);
		}else{
			tmp =set_bit(tmp, 31 - i);
		}
		n = n >> 1;
	}
	return tmp;
}

uint32_t fmul(uint32_t f1, uint32_t f2)
{
	myfloat mf1 = {f1};
	myfloat mf2 = {f2};
	//mf1.muint = bit_round(mf1.muint);
	//mf2.muint = bit_round(mf2.muint);
	//step1 step2
	uint32_t fraction1 = get_fraction(mf1);
	uint32_t fraction1_higher12bit = get_binary_unsigned(fraction1, 9, 21);
	//uint32_t fraction1_higher13bit = set_bit(fraction1_higher12bit << 1, 0);
	uint32_t fraction1_higher13bit = set_bit(fraction1_higher12bit, 12);
	uint32_t fraction1_lower11bit = get_binary_unsigned(fraction1, 21, 32);

	uint32_t fraction2 = get_fraction(mf2);
	uint32_t fraction2_higher12bit = get_binary_unsigned(fraction2, 9, 21);
	//uint32_t fraction2_higher13bit = set_bit(fraction2_higher12bit << 1, 0);
	uint32_t fraction2_higher13bit = set_bit(fraction2_higher12bit, 12);
	uint32_t fraction2_lower11bit = get_binary_unsigned(fraction2, 21, 32);

	//step3
	uint32_t tmp = (fraction1_higher13bit * fraction2_higher13bit) + ((fraction1_higher13bit * fraction2_lower11bit) >> 11 ) + ((fraction2_higher13bit * fraction1_lower11bit) >> 11) + 2;

	//step4
	int is_underflow;
	tmp = step4(tmp, &is_underflow);

	//step5
	uint32_t exponent1 = get_exponent(mf1);
	uint32_t exponent2 = get_exponent(mf2);
	uint32_t exponent_ans = is_underflow ? exponent1 + exponent2 - 126 : exponent1 + exponent2 - 127; 

	uint32_t sign1 = get_sign(mf1);
	uint32_t sign2 = get_sign(mf2);
	uint32_t sign_ans = (sign1 | sign2) - (sign1 & sign2);

	myfloat mf_ans;
	mf_ans.muint = (sign_ans << 31 | (exponent_ans << 23) | tmp);
	return mf_ans.muint;
}
