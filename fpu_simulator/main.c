#include<stdio.h>
#include<math.h>

typedef union myfloat_{
	unsigned int muint;
	float mfloat;
}myfloat;

void print_int2bin(unsigned int n)
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

unsigned int get_binary_unsigned(unsigned int n, int start, int end)
{
	//printf("inst_int = %d\n", inst.inst_int);
	int len = end - start;
	//printf("%int", inst.inst_int);
	n = n << start;
	n = n >> (32 - len);
	return n;
}

unsigned int get_fraction(myfloat mf)
{
	return get_binary_unsigned(mf.muint, 9, 32);
}

unsigned int get_exponent(myfloat mf)
{
	return get_binary_unsigned(mf.muint, 1, 9);
}

unsigned int get_sign(myfloat mf)
{
	return get_binary_unsigned(mf.muint, 0, 1);
}

unsigned int set_bit(unsigned int ui, int idx)
{
	return ui | (unsigned int)pow(2, idx);
}

unsigned int unset_bit(unsigned int ui, int idx)
{
	return ui & (~(unsigned int)pow(2, idx));
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


unsigned int get_msb1_idx(unsigned int ui)
{
	int i;
	unsigned int tmp = (int)pow(2, 31);
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

unsigned int step4(unsigned int tmp)
{
	return get_binary_unsigned(tmp, get_msb1_idx(tmp) + 1, get_msb1_idx(tmp) + 24);
}


unsigned int bit_round(unsigned int n)
{
	unsigned int tmp = 0;
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

myfloat fmul(myfloat mf1, myfloat mf2)
{
	//mf1.muint = bit_round(mf1.muint);
	//mf2.muint = bit_round(mf2.muint);
	//step1 step2
	unsigned int fraction1 = get_fraction(mf1);
	unsigned int fraction1_higher12bit = get_binary_unsigned(fraction1, 9, 21);
	//unsigned int fraction1_higher13bit = set_bit(fraction1_higher12bit << 1, 0);
	unsigned int fraction1_higher13bit = set_bit(fraction1_higher12bit, 12);
	unsigned int fraction1_lower11bit = get_binary_unsigned(fraction1, 21, 32);

	unsigned int fraction2 = get_fraction(mf2);
	unsigned int fraction2_higher12bit = get_binary_unsigned(fraction2, 9, 21);
	//unsigned int fraction2_higher13bit = set_bit(fraction2_higher12bit << 1, 0);
	unsigned int fraction2_higher13bit = set_bit(fraction2_higher12bit, 12);
	unsigned int fraction2_lower11bit = get_binary_unsigned(fraction2, 21, 32);

	//step3
	unsigned int tmp = (fraction1_higher13bit * fraction2_higher13bit) + ((fraction1_higher13bit * fraction2_lower11bit) >> 11 ) + ((fraction2_higher13bit * fraction1_lower11bit) >> 11) + 2;

	//step4
	tmp = step4(tmp);

	//step5
	unsigned int exponent1 = get_exponent(mf1);
	unsigned int exponent2 = get_exponent(mf2);
	unsigned int exponent_ans = (exponent1) + (exponent2) - 127;

	unsigned int sign1 = get_sign(mf1);
	unsigned int sign2 = get_sign(mf2);
	unsigned int sign_ans = (sign1 | sign2) - (sign1 & sign2);

	myfloat mf_ans;
	puts("-----------------");
	print_int2bin(sign_ans << 31);
	print_int2bin(exponent_ans << 23);
	print_int2bin(tmp);
	puts("-----------------");
	mf_ans.muint = (sign_ans << 31 | (exponent_ans << 23) | tmp);
	print_int2bin(mf_ans.muint);
	//mf_ans.muint = bit_round(mf_ans.muint);
	return mf_ans;

}

int main(void)
{
	myfloat mf1;
	mf1.mfloat = 2.6f;
	myfloat mf2;
	mf2.mfloat = 8.9f;
	myfloat mf_ans = fmul(mf1, mf2);
	mf_ans.muint = unset_bit(mf_ans.muint, 0);
	printf("%f\n", mf_ans.mfloat);
	printf("%f\n", mf1.mfloat * mf2.mfloat);
	return 0;
}
