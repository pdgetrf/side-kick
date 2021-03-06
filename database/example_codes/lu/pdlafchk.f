      SUBROUTINE PDLAFCHK( AFORM, DIAG, M, N, A, IA, JA, DESCA, IASEED,
     $                     ANORM, FRESID, WORK )
*
*  -- ScaLAPACK auxiliary routine (version 1.7) --
*     University of Tennessee, Knoxville, Oak Ridge National Laboratory,
*     and University of California, Berkeley.
*     May 1, 1997
*
*     .. Scalar Arguments ..
      CHARACTER          AFORM, DIAG
      INTEGER            IA, IASEED, JA, M, N
      DOUBLE PRECISION   ANORM, FRESID
*     ..
*     .. Array Arguments ..
      INTEGER            DESCA( * )
      DOUBLE PRECISION   A( * ), WORK( * )
*     ..
*
*  Purpose
*  =======
*
*  PDLAFCHK computes the residual
*       || sub( A ) - sub( Ao ) || / (|| sub( Ao ) ||*eps*MAX(M,N)),
*  where Ao will be regenerated by the parallel random matrix generator,
*  sub( A ) = A( IA:IA+M-1, JA:JA+N-1 ) and ||.|| stands for the infini-
*  ty norm.
*
*  Notes
*  =====
*
*  Each global data object is described by an associated description
*  vector.  This vector stores the information required to establish
*  the mapping between an object element and its corresponding process
*  and memory location.
*
*  Let A be a generic term for any 2D block cyclicly distributed array.
*  Such a global array has an associated description vector DESCA.
*  In the following comments, the character _ should be read as
*  "of the global array".
*
*  NOTATION        STORED IN      EXPLANATION
*  --------------- -------------- --------------------------------------
*  DTYPE_A(global) DESCA( DTYPE_ )The descriptor type.  In this case,
*                                 DTYPE_A = 1.
*  CTXT_A (global) DESCA( CTXT_ ) The BLACS context handle, indicating
*                                 the BLACS process grid A is distribu-
*                                 ted over. The context itself is glo-
*                                 bal, but the handle (the integer
*                                 value) may vary.
*  M_A    (global) DESCA( M_ )    The number of rows in the global
*                                 array A.
*  N_A    (global) DESCA( N_ )    The number of columns in the global
*                                 array A.
*  MB_A   (global) DESCA( MB_ )   The blocking factor used to distribute
*                                 the rows of the array.
*  NB_A   (global) DESCA( NB_ )   The blocking factor used to distribute
*                                 the columns of the array.
*  RSRC_A (global) DESCA( RSRC_ ) The process row over which the first
*                                 row of the array A is distributed.
*  CSRC_A (global) DESCA( CSRC_ ) The process column over which the
*                                 first column of the array A is
*                                 distributed.
*  LLD_A  (local)  DESCA( LLD_ )  The leading dimension of the local
*                                 array.  LLD_A >= MAX(1,LOCr(M_A)).
*
*  Let K be the number of rows or columns of a distributed matrix,
*  and assume that its process grid has dimension p x q.
*  LOCr( K ) denotes the number of elements of K that a process
*  would receive if K were distributed over the p processes of its
*  process column.
*  Similarly, LOCc( K ) denotes the number of elements of K that a
*  process would receive if K were distributed over the q processes of
*  its process row.
*  The values of LOCr() and LOCc() may be determined via a call to the
*  ScaLAPACK tool function, NUMROC:
*          LOCr( M ) = NUMROC( M, MB_A, MYROW, RSRC_A, NPROW ),
*          LOCc( N ) = NUMROC( N, NB_A, MYCOL, CSRC_A, NPCOL ).
*  An upper bound for these quantities may be computed by:
*          LOCr( M ) <= ceil( ceil(M/MB_A)/NPROW )*MB_A
*          LOCc( N ) <= ceil( ceil(N/NB_A)/NPCOL )*NB_A
*
*  Arguments
*  =========
*
*  AFORM   (global input) CHARACTER
*          sub( A ) is overwritten with:
*             - a symmetric matrix, if AFORM = 'S';
*             - a Hermitian matrix, if AFORM = 'H';
*             - the transpose of what would normally be generated,
*               if AFORM = 'T';
*             - the conjugate transpose of what would normally be
*               generated, if AFORM = 'C';
*             - otherwise a random matrix.
*
*  DIAG    (global input) CHARACTER
*          if DIAG = 'D' : sub( A ) is diagonally dominant.
*
*  M       (global input) INTEGER
*          The number of rows to be operated on, i.e. the number of rows
*          of the distributed submatrix sub( A ). M >= 0.
*
*  N       (global input) INTEGER
*          The number of columns to be operated on, i.e. the number of
*          columns of the distributed submatrix sub( A ). N >= 0.
*
*  A       (local input/local output) DOUBLE PRECISION pointer into the
*          local memory to an array of dimension (LLD_A,LOCc(JA+N-1)).
*          On entry, this array contains the local pieces of the M-by-N
*          distributed matrix sub( A ) to be checked. On exit, this
*          array contains the local pieces of the difference
*          sub( A ) - sub( Ao ).
*
*  IA      (global input) INTEGER
*          The row index in the global array A indicating the first
*          row of sub( A ).
*
*  JA      (global input) INTEGER
*          The column index in the global array A indicating the
*          first column of sub( A ).
*
*  DESCA   (global and local input) INTEGER array of dimension DLEN_.
*          The array descriptor for the distributed matrix A.
*
*  IASEED  (global input) INTEGER
*          The seed number to generate the original matrix Ao.
*
*  ANORM   (global input) DOUBLE PRECISION
*          The Infinity norm of sub( A ).
*
*  FRESID  (global output) DOUBLE PRECISION
*          The maximum (worst) factorizational error.
*
*  WORK    (local workspace) DOUBLE PRECISION array, dimension (LWORK).
*          LWORK >= MpA0 * NB_A, where
*
*          IROFFA = MOD( IA-1, MB_A ),
*          IAROW = INDXG2P( IA, MB_A, MYROW, RSRC_A, NPROW ),
*          MpA0 = NUMROC( M+IROFFA, MB_A, MYROW, IAROW, NPROW ),
*
*          WORK is used to store a block of columns of sub( A ).
*          INDXG2P and NUMROC are ScaLAPACK tool functions; MYROW,
*          MYCOL, NPROW and NPCOL can be determined by calling the
*          subroutine BLACS_GRIDINFO.
*
*  =====================================================================
*
*     .. Parameters ..
      INTEGER            BLOCK_CYCLIC_2D, CSRC_, CTXT_, DLEN_, DTYPE_,
     $                   LLD_, MB_, M_, NB_, N_, RSRC_
      PARAMETER          ( BLOCK_CYCLIC_2D = 1, DLEN_ = 9, DTYPE_ = 1,
     $                     CTXT_ = 2, M_ = 3, N_ = 4, MB_ = 5, NB_ = 6,
     $                     RSRC_ = 7, CSRC_ = 8, LLD_ = 9 )
      DOUBLE PRECISION   ONE
      PARAMETER          ( ONE = 1.0D+0 )
*     ..
*     .. Local Scalars ..
      INTEGER            IACOL, IAROW, ICOFF, ICTXT, IIA, IOFFA, IROFF,
     $                   JB, JJ, JJA, JN, LDA, LDW, MP, MYCOL, MYROW,
     $                   NPCOL, NPROW, NQ
      DOUBLE PRECISION   EPS
*     ..
*     .. External Subroutines ..
      EXTERNAL           BLACS_GRIDINFO, DMATADD, INFOG2L, PDMATGEN
*     ..
*     .. External Functions ..
      INTEGER            ICEIL, NUMROC
      DOUBLE PRECISION   PDLAMCH, PDLANGE
      EXTERNAL           ICEIL, NUMROC, PDLAMCH, PDLANGE
*     ..
*     .. Intrinsic Functions ..
      INTRINSIC          MAX, MIN, MOD
*     ..
*     .. Executable Statements ..
*
      ICTXT = DESCA( CTXT_ )
      CALL BLACS_GRIDINFO( ICTXT, NPROW, NPCOL, MYROW, MYCOL )
      EPS = PDLAMCH( ICTXT, 'eps' )
      CALL INFOG2L( IA, JA, DESCA, NPROW, NPCOL, MYROW, MYCOL, IIA, JJA,
     $              IAROW, IACOL )
*
*     Compute sub( A ) := sub( A ) - sub( Ao )
*
      IROFF = MOD( IA-1, DESCA( MB_ ) )
      ICOFF = MOD( JA-1, DESCA( NB_ ) )
      MP = NUMROC( M+IROFF, DESCA( MB_ ), MYROW, IAROW, NPROW )
      NQ = NUMROC( N+ICOFF, DESCA( NB_ ), MYCOL, IACOL, NPCOL )
      IF( MYROW.EQ.IAROW )
     $   MP = MP-IROFF
      IF( MYCOL.EQ.IACOL )
     $   NQ = NQ-ICOFF
      JN = MIN( ICEIL( JA, DESCA( NB_ ) ) * DESCA( NB_ ), JA+N-1 )
      LDW = MAX( 1, MP )
      LDA = DESCA( LLD_ )
      IOFFA = IIA + ( JJA - 1 )*LDA
*
*     Handle first block of columns separately
*
      IF( MYCOL.EQ.IACOL ) THEN
         JB = JN-JA+1
         CALL PDMATGEN( ICTXT, AFORM, DIAG, DESCA( M_ ), DESCA( N_ ),
     $                  DESCA( MB_ ), DESCA( NB_ ), WORK, LDW,
     $                  DESCA( RSRC_ ), DESCA( CSRC_ ), IASEED, IIA-1,
     $                  MP, JJA-1, JB, MYROW, MYCOL, NPROW, NPCOL )
         CALL DMATADD( MP, JB, -ONE, WORK, LDW, ONE, A( IOFFA ), LDA )
         JJA = JJA + JB
         NQ  = NQ - JB
         IOFFA = IOFFA + JB * LDA
      END IF
*
*     Handle the remaning blocks of columns
*
      DO 10 JJ = JJA, JJA+NQ-1, DESCA( NB_ )
         JB = MIN( DESCA( NB_ ), JJA+NQ-JJ )
         IOFFA = IIA + ( JJ - 1 ) * LDA
         CALL PDMATGEN( ICTXT, AFORM, DIAG, DESCA( M_ ), DESCA( N_ ),
     $                  DESCA( MB_ ), DESCA( NB_ ), WORK, LDW,
     $                  DESCA( RSRC_ ), DESCA( CSRC_ ), IASEED, IIA-1,
     $                  MP, JJ-1, JB, MYROW, MYCOL, NPROW, NPCOL )
         CALL DMATADD( MP, JB, -ONE, WORK, LDW, ONE, A( IOFFA ), LDA )
   10 CONTINUE
*
*     Calculate factor residual
*
      FRESID = PDLANGE( 'I', M, N, A, IA, JA, DESCA, WORK ) /
     $                  ( MAX( M, N ) * EPS * ANORM )
*
      RETURN
*
*     End PDLAFCHK
*
      END
