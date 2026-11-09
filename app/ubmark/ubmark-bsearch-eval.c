//========================================================================
// ubmark-bsearch-eval
//========================================================================

#include "ece4750.h"
#include "ubmark-bsearch.h"
#include "ubmark-bsearch.dat"

int main( void )
{
  // Allocate destination array for results

  int* idxs = ece4750_malloc( eval_search_keys_size * (int)sizeof(int) );

  // Run the evaluation

  ece4750_stats_on();

  ubmark_bsearch( idxs, eval_search_keys, eval_search_keys_size,
                  eval_sorted_keys, eval_sorted_keys_size );

  ece4750_stats_off();

  // Verify the results

  for ( int i = 0; i < eval_search_keys_size; i++ ) {
    if ( idxs[i] != eval_ref[i] ) {
      ece4750_wprintf( L"\n FAILED: idxs[%d] != eval_ref[%d] (%d != %d)\n\n",
                       i, i, idxs[i], eval_ref[i] );
      ece4750_exit(1);
    }
  }

  // Free destination array

  ece4750_free(idxs);

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

