//========================================================================
// ubmark-accum-eval
//========================================================================

#include "ece4750.h"
#include "ubmark-accum.h"
#include "ubmark-accum.dat"

int main( void )
{
  // Run the evaluation

  ece4750_stats_on();
  int result = ubmark_accum( eval_src, eval_size );
  ece4750_stats_off();

  // Verify the results

  for ( int i = 0; i < eval_size; i++ ) {
    if ( result != eval_ref ) {
      ece4750_wprintf( L"\n FAILED: result != eval_ref (%d != %d)\n\n",
                       result, eval_ref );
      ece4750_exit(1);
    }
  }

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

