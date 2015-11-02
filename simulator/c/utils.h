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

void print_char2bin(unsigned char c)
{
	unsigned char buf[8];
	int i;
	for(i = 0; i < 8; i++){
		if(c % 2 == 0){
			buf[i] = '0';
		}else{
			buf[i] = '1';
		}
		c = c >> 1;
	}
	for(i = 0; i < 8; i++){
		printf("%c", buf[7 - i]);
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

int get_binary_signed(int n, int start, int end)
{
	//printf("inst_int = %d\n", inst.inst_int);
	int len = end - start;
	//printf("%int", inst.inst_int);
	n = n << start;
	n = n >> (32 - len);
	return n;
}
