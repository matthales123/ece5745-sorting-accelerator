//========================================================================
// Unit tests for ubmark cmult
//========================================================================

#include "ece4750.h"
#include "ubmark-cmult.h"
#include "ubmark-cmult.dat"

//------------------------------------------------------------------------
// Test with single complex multiply
//------------------------------------------------------------------------

void test_case_1_basic()
{
  ECE4750_CHECK( L"test_case_1_basic" );

  complex_t src0[] = { { 1, 2} };
  complex_t src1[] = { { 5, 6} };
  complex_t dest[] = { { 0, 0} };
  complex_t ref[]  = { {-7,16} };

  ubmark_cmult( dest, src0, src1, 1 );

  ECE4750_CHECK_INT_EQ( dest[0].re, ref[0].re );
  ECE4750_CHECK_INT_EQ( dest[0].im, ref[0].im );
}

//------------------------------------------------------------------------
// Test with positive inputs
//------------------------------------------------------------------------

void test_case_2_pos()
{
  ECE4750_CHECK( L"test_case_2_pos" );

  complex_t src0[] = { {  1,  2}, {  3,  4}, {  5,   6}, {  7,  8} };
  complex_t src1[] = { {  9, 10}, { 11, 12}, { 13,  14}, { 15, 16} };
  complex_t dest[] = { {  0,  0}, {  0,  0}, {  0,   0}, {  0,  0} };
  complex_t ref[]  = { {-11, 28}, {-15, 80}, {-19, 148}, {-23,232} };

  ubmark_cmult( dest, src0, src1, 4 );

  for ( int i = 0; i < 4; i++ ) {
    ECE4750_CHECK_INT_EQ( dest[i].re, ref[i].re );
    ECE4750_CHECK_INT_EQ( dest[i].im, ref[i].im );
  }
}

//------------------------------------------------------------------------
// Test with negative inputs
//------------------------------------------------------------------------

void test_case_3_neg()
{
  ECE4750_CHECK( L"test_case_3_neg" );

  complex_t src0[] = { { -1, -2}, { -3, -4}, { -5, -6}, { -7, -8} };
  complex_t src1[] = { { -9,-10}, {-11,-12}, {-13,-14}, {-15,-16} };
  complex_t dest[] = { {  0,  0}, {  0,  0}, {  0,  0}, {  0,  0} };
  complex_t ref[]  = { {-11, 28}, {-15, 80}, {-19,148}, {-23,232} };

  ubmark_cmult( dest, src0, src1, 4 );

  for ( int i = 0; i < 4; i++ ) {
    ECE4750_CHECK_INT_EQ( dest[i].re, ref[i].re );
    ECE4750_CHECK_INT_EQ( dest[i].im, ref[i].im );
  }
}


//------------------------------------------------------------------------
// Test eval dataset
//------------------------------------------------------------------------

void test_case_4_eval_dataset()
{
  ECE4750_CHECK( L"test_case_4_eval_dataset" );

  complex_t* dest = ece4750_malloc( eval_size * (int)sizeof(complex_t) );

  ubmark_cmult( dest, eval_src0, eval_src1, eval_size );

  for ( int i = 0; i < eval_size; i++ ) {
    ECE4750_CHECK_INT_EQ( dest[i].re, eval_ref[i].re );
    ECE4750_CHECK_INT_EQ( dest[i].im, eval_ref[i].im );
  }

  ece4750_free(dest);
}

//------------------------------------------------------------------------
// main
//------------------------------------------------------------------------

int main( int argc, char** argv )
{
  __n = ( argc == 1 ) ? 0 : ece4750_atoi( argv[1] );

  if ( (__n <= 0) || (__n == 1) ) test_case_1_basic();
  if ( (__n <= 0) || (__n == 2) ) test_case_2_pos();
  if ( (__n <= 0) || (__n == 3) ) test_case_3_neg();
  if ( (__n <= 0) || (__n == 4) ) test_case_4_eval_dataset();

  ece4750_wprintf( L"\n\n" );
  return ece4750_check_status;
}

