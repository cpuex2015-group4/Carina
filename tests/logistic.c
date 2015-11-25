/*
let rec logistic a n x0 =
  if n = 0 then x0
  else
    let x = logistic a (n - 1) x0 in
    a *. x *. (1.0 -. x)
in (logistic 3.8 15 0.5)
	*/

#include <stdio.h>

float logistic(float a, int n, float x0) {
	if(n == 0) {
		return x0;
	} else {
		float x = logistic(a, n-1, x0);
		return a * x * (1-x);
	}
}

int main() {
	float res = logistic(3.8, 15, 0.5);
	printf("%.8f\n", res);
	return 0;
}
