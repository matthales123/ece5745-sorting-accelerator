//========================================================================
// ubmark-accum
//========================================================================

#include "ubmark-accum.h"

int ubmark_accum( int* src, int size )
{
  int sum = 0;
  for ( int i = 0; i < size; i++ )
    sum += src[i];
  return sum;
}

