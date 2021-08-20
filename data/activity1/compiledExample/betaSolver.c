/* betaColver.c - An excessive program to return the beta of a gamma distribution given a mean and alpha */
#include <stdio.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include "betaSolver.h"

int main(int argc, char *argv[])
{
  double mean = 0.0;
  double alpha = 0.0;
  for (int i = 1; i < argc; i++)
    {
      if (strcmp(argv[i], "-h") == 0 || strcmp(argv[i], "--help") == 0)
	{
	  printf("Most programs will display a help menu if you pass -h as a flag\n");
	  printf("This program accepts two arguments:\n");
	  printf("-m or --mean <mean of gamma distirbution>\n");
	  printf("-a or --alpha <alpha of gamma distirbution>\n");		 
	  exit(0);
	}
      else if (strcmp(argv[i], "-m") == 0 || strcmp(argv[i], "--mean") == 0)
	{
	  sscanf(argv[i+1],"%lf",&mean);
	}
      else if (strcmp(argv[i], "-a") == 0 || strcmp(argv[i], "--alpha") == 0)
	{
	  sscanf(argv[i+1],"%lf",&alpha);
	}
    }

  if (mean > 0 && alpha > 0)
    {
      solveBeta(mean,alpha);
    }
  return 0;
}
