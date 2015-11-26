/* sqrt.c
   情報科学科 05-151007 今井雄毅
   Sun Nov 22 23:33:52 2015 */
#include<stdlib.h>
#include<stdio.h>

#define DEBUG

#ifdef DEBUG then
#include<math.h>
#endif

float quicksqrt( float number )
{
  long i;
  float x2, y;
  const float threehalfs = 1.5F;
  x2 = number * 0.5F;
  y  = number;
  i  = * ( long * ) &y;
  i  = 0x5f3759df - ( i >> 1 );
  y  = * ( float * ) &i;
  y  = y * ( threehalfs - ( x2 * y * y ) );
  return y;
}
