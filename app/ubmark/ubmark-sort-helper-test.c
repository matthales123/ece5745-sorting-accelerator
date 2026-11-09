//========================================================================
// Unit tests for ubmark sort helper functions
//========================================================================

#include "ece4750.h"
#include "ubmark-sort.h"

//------------------------------------------------------------------------
// test_case_1_swap
//------------------------------------------------------------------------
// Test swap helper function

void test_case_1_swap()
{
  ECE4750_CHECK( L"test_case_1_swap" );

  int a = 1;
  int b = 2;

  ubmark_sort_swap( &a, &b );

  ECE4750_CHECK_INT_EQ( a, 2 );
  ECE4750_CHECK_INT_EQ( b, 1 );

  ubmark_sort_swap( &a, &b );

  ECE4750_CHECK_INT_EQ( a, 1 );
  ECE4750_CHECK_INT_EQ( b, 2 );

  ECE4750_CHECK_INT_EQ( ece4750_get_heap_usage(), 0 );
}

//------------------------------------------------------------------------
// test_case_2_partition_simple
//------------------------------------------------------------------------
// Test partition helper function with simple input

void test_case_2_partition_simple()
{
  ECE4750_CHECK( L"test_case_2_partition_simple" );

  int size = 8;
  int a[]  = { 1, 9, 7, 5, 0, 4, 2, 3 };
  int p    = ubmark_sort_partition( a, 0, size );

  // Check if elements to the left of pivot is not greater than the pivot
  for ( int i = 0; i < p; i++ )
    ECE4750_CHECK_TRUE( a[i] <= a[p] );

  // Check if elements to the right of pivot is not smaller than the pivot
  for ( int i = p; i < size; i++ )
    ECE4750_CHECK_TRUE( a[i] >= a[p] );

  ECE4750_CHECK_INT_EQ( ece4750_get_heap_usage(), 0 );
}

//------------------------------------------------------------------------
// test_case_3_partition_sorted_asc
//------------------------------------------------------------------------
// Test paritition helper function with sorted array in ascending order

void test_case_3_partition_sorted_asc()
{
  ECE4750_CHECK( L"test_case_3_partition_sorted_asc" );

  int size = 8;
  int a[]  = { 1, 2, 3, 4, 5, 6, 7, 8 };
  int p    = ubmark_sort_partition( a, 0, size );

  // Check if elements to the left of pivot is not greater than the pivot
  for ( int i = 0; i < p; i++ )
    ECE4750_CHECK_TRUE( a[i] <= a[p] );

  // Check if elements to the right of pivot is not smaller than the pivot
  for ( int i = p; i < size; i++ )
    ECE4750_CHECK_TRUE( a[i] >= a[p] );

  ECE4750_CHECK_INT_EQ( ece4750_get_heap_usage(), 0 );
}

//------------------------------------------------------------------------
// test_case_4_partition_sorted_desc
//------------------------------------------------------------------------
// Test paritition helper function with sorted array in descending order

void test_case_4_partition_sorted_desc()
{
  ECE4750_CHECK( L"test_case_4_partition_sorted_desc" );

  int size = 8;
  int a[]  = { 8, 7, 6, 5, 4, 3, 2, 1 };
  int p    = ubmark_sort_partition( a, 0, size );

  // Check if elements to the left of pivot is not greater than the pivot
  for ( int i = 0; i < p; i++ )
    ECE4750_CHECK_TRUE( a[i] <= a[p] );

  // Check if elements to the right of pivot is not smaller than the pivot
  for ( int i = p; i < size; i++ )
    ECE4750_CHECK_TRUE( a[i] >= a[p] );

  ECE4750_CHECK_INT_EQ( ece4750_get_heap_usage(), 0 );
}

//------------------------------------------------------------------------
// test_case_5_partition_duplicate
//------------------------------------------------------------------------
// Test partition helper function with duplicate

void test_case_5_partition_duplicate()
{
  ECE4750_CHECK( L"test_case_5_partition_duplicate" );

  int size = 8;
  int a[]  = { 0, 9, 9, 3, 3, 4, 4, 3 };
  int p    = ubmark_sort_partition( a, 0, size );

  // Check if elements to the left of pivot is not greater than the pivot
  for ( int i = 0; i < p; i++ )
    ECE4750_CHECK_TRUE( a[i] <= a[p] );

  // Check if elements to the right of pivot is not smaller than the pivot
  for ( int i = p; i < size; i++ )
    ECE4750_CHECK_TRUE( a[i] >= a[p] );

  ECE4750_CHECK_INT_EQ( ece4750_get_heap_usage(), 0 );
}

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

int main( int argc, char** argv )
{
  __n = ( argc == 1 ) ? 0 : ece4750_atoi( argv[1] );

  if ( (__n <= 0) || (__n == 1 ) ) test_case_1_swap();
  if ( (__n <= 0) || (__n == 2 ) ) test_case_2_partition_simple();
  if ( (__n <= 0) || (__n == 3 ) ) test_case_3_partition_sorted_asc();
  if ( (__n <= 0) || (__n == 4 ) ) test_case_4_partition_sorted_desc();
  if ( (__n <= 0) || (__n == 5 ) ) test_case_5_partition_duplicate();

  //''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''/\

  ece4750_wprintf( L"\n\n" );
  return ece4750_check_status;
}
