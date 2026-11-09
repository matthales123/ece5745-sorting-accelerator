//========================================================================
// ece4750-malloc
//========================================================================

#include "ece4750-malloc.h"
#include "ece4750-misc.h"
#include "ece4750-bthread.h"
#include "ece4750-wprint.h"

//------------------------------------------------------------------------
// global variables
//------------------------------------------------------------------------

int ece4750_malloc_heap_usage = 0;

//------------------------------------------------------------------------
// ece4750_malloc
//------------------------------------------------------------------------
// We save the number of bytes allocated on the heap right before the
// pointer to the newly allocated storage so we can use this to track the
// total mem usage (and assert there are no memory leaks!).

#ifdef _RISCV

void* ece4750_malloc( int mem_size )
{
  // Malloc is not thread save. Can only run malloc on core 0; if we are
  // on cores 1-3 we cannot use wprintf so we just exit which will send a
  // message to one of the sinks which will then cause a stream sink
  // error.

  int core_id = ece4750_bthread_get_core_id();
  if ( core_id != 0 )
    ece4750_exit(1);

  // Check if requested number of bytes is just way too large. We only
  // support 1MB of virtual/physical memory, so clearly if the user asks
  // for more than this it is an error. Since we know we are running on
  // core 0 now we can use wprintf to print an error message before
  // exiting.

  if ( mem_size > (1 << 20) ) {
    ece4750_wprintf( L"\n\n ERROR: Cannot malloc more than 1MB!\n\n" );
    ece4750_exit(1);
  }

  extern unsigned char _end; // defined in linker script
  static unsigned char* heap_end;
  unsigned char* prev_heap_end;

  if ( heap_end == 0 )
    heap_end = &_end;

  prev_heap_end = heap_end;
  heap_end += 4 + mem_size;

  // Do not allow the heap to grow so large that it overwrites the stack.
  // In the single-core system, the stack starts at 0xff000. In the
  // multi-core system, the stack for core 0 still starts at 0xff000, but
  // the stack for core 3 starts at 0xf3000. So we conservatively do not
  // allow the heap to grow above 0xf3000 which should be plenty of heap
  // space.

  if ( heap_end >= (unsigned char*) 0xf3000 ) {
    ece4750_wprintf( L"\n\n ERROR: Out of heap space!\n\n" );
    ece4750_exit(1);
  }

  // Increment global mem usage and save mem size on heap
  ece4750_malloc_heap_usage += (int) mem_size;
  ((int*) prev_heap_end)[0] = mem_size;

  return 4 + prev_heap_end;
}

#else

inline
void* ece4750_malloc( int mem_size )
{
  void* ptr = malloc( (size_t) mem_size + sizeof( int ) );

  if ( ptr )
    ece4750_malloc_heap_usage += (int) mem_size;
  else
    return NULL;

  ( (int*) ptr )[0] = (int) mem_size;

  return (void*) ( ( (int*) ptr ) + 1 );
}

#endif

//------------------------------------------------------------------------
// ece4750_free
//------------------------------------------------------------------------
// We decrement the total mem usage so we can assert there are no memory
// leaks! Note that on RISCV we don't actually free the storage so we can
// easily run out of memory.

#ifdef _RISCV

void ece4750_free( void* ptr )
{
  if ( ptr )
    ece4750_malloc_heap_usage -= ( (int*) ptr )[-1];
}

#else

inline
void ece4750_free( void* ptr )
{
  if ( ptr ) {
    ece4750_malloc_heap_usage -= ( (int*) ptr )[-1];
    free( ( ( (int*) ptr ) - 1 ) );
  }
}

#endif

//------------------------------------------------------------------------
// ece2400_get_heap_usage
//------------------------------------------------------------------------
// Return the amount of heap space that has been allocated so far in a
// program.

int ece4750_get_heap_usage()
{
  return ece4750_malloc_heap_usage;
}

