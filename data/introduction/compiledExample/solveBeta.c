/* solveBeta.c - the solveBeta function for the betaSolver program */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include "betaSolver.h"

void solveBeta(double mean, double alpha)
{
  double beta;
  beta = alpha/mean;
  printf("The beta (rate) parameter is: %0.3f\n", beta);
}
