//========================================================================
// ubmark-cmult-eval
//========================================================================

#include "ece4750.h"
#include "ubmark-cmult.h"
#include "ubmark-cmult.dat"

int main( void )
{
  // Allocate destination array for results

  complex_t* dest = ece4750_malloc( eval_size * (int)sizeof(complex_t) );

  // Run the evaluation

  ece4750_stats_on();
  ubmark_cmult( dest, eval_src0, eval_src1, eval_size );
  ece4750_stats_off();

  // Verify the results

  for ( int i = 0; i < eval_size; i++ ) {

    if ( dest[i].re != eval_ref[i].re ) {
      ece4750_wprintf( L"\n FAILED: dest[%d].re != eval_ref[%d].re (%d != %d)\n\n",
                       i, i, dest[i].re, eval_ref[i].re );
      ece4750_exit(1);
    }

    if ( dest[i].im != eval_ref[i].im ) {
      ece4750_wprintf( L"\n FAILED: dest[%d].im != eval_ref[%d].im (%d != %d)\n\n",
                       i, i, dest[i].im, eval_ref[i].im );
      ece4750_exit(1);
    }

  }

  // Free destination array

  ece4750_free(dest);

  // Check for no memory leaks

  if ( ece4750_get_heap_usage() != 0 ) {
    ece4750_wprintf( L"\n FAILED: memory leak of %d bytes!\n\n",
                     ece4750_get_heap_usage() );
    ece4750_exit(1);
  }

  // Otherwise we passed

  ece4750_wprintf( L"\n **PASSED** \n\n" );

  return 0;
}

