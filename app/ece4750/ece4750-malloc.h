//========================================================================
// ece4750-malloc
// ========================================================================
// Very, very simple bump pointer malloc. Very easy to run out of memory.
// If you try and malloc too many bytes or the heap reaches the stack it
// will print out an error and exit the program. This malloc is _not_
// thread safe. If you call malloc on cores 1-3 it will cause an error.
// You can use ece4750_get_heap_usage to check if there are any memory
// leaks.

#ifndef ECE4750_MALLOC_H
#define ECE4750_MALLOC_H

#include "ece4750-misc.h"

#ifndef _RISCV
#include <stdlib.h>
#endif

//------------------------------------------------------------------------
// ece4750_malloc
//------------------------------------------------------------------------

void* ece4750_malloc( int mem_size );

//------------------------------------------------------------------------
// ece4750_free
//------------------------------------------------------------------------

void ece4750_free( void* ptr );

//------------------------------------------------------------------------
// ece4750_get_heap_usage
//------------------------------------------------------------------------

int ece4750_get_heap_usage();

#endif /* ECE4750_MISC_H */

