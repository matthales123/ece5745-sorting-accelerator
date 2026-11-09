//========================================================================
// ubmark-mfilt-eval
//========================================================================

#include "ece4750.h"
#include "ubmark-mfilt.h"
#include "ubmark-mfilt.dat"

int main( void )
{
  // Allocate destination array for results

  int* dest = ece4750_malloc( eval_size*eval_size * (int)sizeof(int) );

  // Run the evaluation

  ece4750_stats_on();
  ubmark_mfilt( dest, eval_mask, eval_src, eval_size );
  ece4750_stats_off();

  // Verify the results

  for ( int i = 0; i < eval_size*eval_size; i++ ) {
    if ( dest[i] != eval_ref[i] ) {
      ece4750_wprintf( L"\n FAILED: dest[%d] != eval_ref[%d] (%d != %d)\n\n",
                       i, i, dest[i], eval_ref[i] );
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

