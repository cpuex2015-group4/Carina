#include <stdio.h>
#include <stdint.h>

#define BIT(x,n)      (((x) >> ((n)-1)) & 1)

#define EMAX32        127

#define MASK_EXPONENT 0xff
#define MASK_MANTISSA 0x7fffff
#define MSB           (MASK_MANTISSA+1)

#define SIGN(x)      (((x)>>31)&1)
#define EXPONENT(x)  (((x)>>23)&MASK_EXPONENT)
#define MANTISSA(x)  ((x)&MASK_MANTISSA)

#define FLOAT(s,e,m) ((((s)&1)<<31)|(((e)&MASK_EXPONENT)<<23)|((m)&MASK_MANTISSA))
#define INF          FLOAT(0,255,0)
#define ISINF(x)     (((x)&0x7fffffff)==0x7f800000)
#define NAN          FLOAT(0,255,0x4ffff)
#define ISNAN(x)     ((EXPONENT(x)==0xff)&&(MANTISSA(x)!=0))

void dumpsub(uint32_t d, int cnt) {
	if(cnt > 0) {
		dumpsub(d >> 1, cnt - 1);
		printf("%d", d & 1);
	}
}

void dump(uint32_t d, int cnt) {
	dumpsub(d, cnt);
	printf("\n");
}

/* round even: [n] guard bit -> 23bit mantissa */
uint32_t roundeven(uint32_t fs, uint32_t fe, uint32_t fm, int n) {
	uint32_t G = (fm >> (n-1)) & 1;
	uint32_t R = 0;
	uint32_t ulp = (fm >> n) & 1;
	int i;
	for(i = 0; i < n - 1; i++) {
		R |= ((fm >> i) & 1);
	}
	if(G & (ulp | R)) {
		return FLOAT(fs, fe+1, (fm >> n) + 1);
	} else {
		return FLOAT(fs, fe, fm >> n);
	}
}

uint32_t fgte(uint32_t a, uint32_t b) {
	return FLOAT(0, EXPONENT(a), MANTISSA(a)) >= FLOAT(0, EXPONENT(b), MANTISSA(b));
}

uint32_t shifter(uint32_t f, int n) {
	int i;
	for(i = 0; i < n; i++) {
		int b = f & 1;
		if(b == 0) {
			f = f >> 1;
		} else {
			f = (f >> 1) || 1;
		}
	}
	return f;
}

/* find the position of first '1' bit in [n]bit array f */
int priority_encoder(uint32_t f, uint32_t n) {
	int i;
	for(i = n; i >= 0; i--) {
		if(((f >> i) & 1) == 1) { return n-i; }
	}
	return -1;
}

uint32_t fadd(uint32_t a, uint32_t b) {
	uint32_t as = SIGN(a);     /* sign     of a */
	uint32_t ae = EXPONENT(a); /* exponent of a */
	uint32_t am = MANTISSA(a); /* mantissa of a */
	uint32_t bs = SIGN(b);     /* sign     of b */
	uint32_t be = EXPONENT(b); /* exponent of b */
	uint32_t bm = MANTISSA(b); /* mantissa of b */
	uint32_t fs = 0;
	uint32_t fe = 0;
	uint32_t fm = 0;
	uint32_t f = 0;

	if(ae == 0) {
		return b;
	} else if(be == 0) {
		return a;
	} else if((a & 0x7fffffff) == (b & 0x7fffffff) && SIGN(a) != SIGN(b) && !ISINF(a) && !ISINF(b) && !ISNAN(a) && !ISNAN(b)) {
		return 0;
	} else if(!fgte(a, b)) {
		return fadd(b, a);
	} else if(ISNAN(a)) {
		return NAN;
	} else if(ISINF(a)) {
		return (ISINF(b)) ? (as == bs ? a : NAN) : a;
	} else {
		/* a >= b */
		uint32_t expdiff = ae - be;
		/* add G bit and R bit */
		uint32_t guard;
		switch((int)(as != bs)) {
			case 0: guard = 2; break;
			case 1: guard = 3; break;
		}
		am = am << guard;
		bm = shifter((bm | MSB) << guard, expdiff);

		if(as != bs) {
			// get complement of b's mantissa
			bm = (~bm+1);
		}

		fs = as;
		fe = ae;
		fm = am + bm;

		// regularize
		if(as == bs) {
			// [positive] + [positive]
			if((BIT(fm, 24+guard) == 1) || (((fm >> 1) & 0xffffff) == 0xffffff)) {
				// carry
				fe = fe + 1;
			}
		} else {
			// [positive] + [negative]
			switch(expdiff) {
				case 0:
				case 1:
					{
						int n = priority_encoder(fm, 22+guard);
						fm = fm << (n + 1);
						fe = fe - (n + 1);
					}
					break;
				default:
					if((BIT(fm, 24+guard) == 1)) {
						// carry
						fe = fe - 1;
						fm = fm << 1;
					}
					break;
			}
		}

		f = roundeven(fs, fe, fm, guard);

		if(EXPONENT(f) == 255) { f = INF; }

		return f;
	}
}
