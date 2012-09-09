#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include "slp.h"
#include "util_ft.h"
#include "driver.h"

#define here MPI_Barrier (MPI_COMM_WORLD);\
				printf ("here\n");

#define checkerror(a,b)	\
			{if ((a)!=(b)) \
				{	printf ("error on line %d in %s\n", __LINE__, __FILE__);\
					exit(0);}}

void printout_devices( );

int err_step=1;
int err_block=1;
int real_err_step;

int err_XX=1;	// myrow
int err_YY=1;	// mycol, both are 0-based
int cc;


int main(int argc, char **argv) 
{
	double *A=NULL, *Aorg=NULL;
	int descA[9]; 
	int ictxt;
	int nb, i;
	int np_A, nq_A;
	int ione=1, izero=0;
	double resid;
	int info;
	int nprocs;
	int M, N;
	int start, end, step;
	int iam;
	int myrank_mpi, nprocs_mpi;
	int myrow, mycol;
	int nprow, npcol;
	double MPIt1, MPIt2, MPIelapsed2;
	double GF2=0;
	int *ipiv;

	cc=0;
	nprow = npcol = 1;
	nb = 80;
	start = end = step = 640;


	/* 
	 * read command line parameter 
	 */
	{
		for( i = 1; i < argc; i++ ) 
		{
			if( strcmp( argv[i], "-p" ) == 0 ) 
			{
				nprow  = atoi(argv[i+1]);
				i++;
			}
			if( strcmp( argv[i], "-q" ) == 0 ) 
			{
				npcol  = atoi(argv[i+1]);
				i++;
			}
			if( strcmp( argv[i], "-nb" ) == 0 ) 
			{
				nb     = atoi(argv[i+1]);
				i++;
			}
			if( strcmp( argv[i], "-r" ) == 0 ) 
			{
				start  = atoi(argv[i+1]);
				end = atoi(argv[i+2]);
				step = atoi(argv[i+3]);
				i+=3;
			}
			if( strcmp( argv[i], "-ex" ) == 0 ) 
			{
				err_XX = atoi(argv[i+1]);
				i++;
			}
			if( strcmp( argv[i], "-ey" ) == 0 ) 
			{
				err_YY = atoi(argv[i+1]);
				i++;
			}
			if( strcmp( argv[i], "-estep" ) == 0 ) 
			{
				err_step = atoi(argv[i+1]);
				i++;
			}
			if( strcmp( argv[i], "-eblock" ) == 0 ) 
			{
				err_block = atoi(argv[i+1]);
				i++;
			}
		}
	}	

	/*  
	 *  set up MPI
	 */    
	{
		MPI_Init( &argc, &argv);
		MPI_Comm_rank(MPI_COMM_WORLD, &myrank_mpi);
		MPI_Comm_size(MPI_COMM_WORLD, &nprocs_mpi);
	}

	/*
	 * init BLACS 
	 */
	{
		Cblacs_pinfo( &iam, &nprocs );
		Cblacs_get( -1, 0, &ictxt );
		Cblacs_gridinit( &ictxt, "Row", nprow, npcol );
		Cblacs_gridinfo( ictxt, &nprow, &npcol, &myrow, &mycol );

		if (nprow*npcol > nprocs_mpi)
		{
			if (myrank_mpi==0)
				printf(" **** ERROR : processor grid not compatible with available processors\n");
			printf(" **** Bye-bye                                                                         ***\n");
			MPI_Finalize(); exit(1);
		}
	}
	if (myrank_mpi==0)
		printf ("done setting up MPI and BLACS, nprow=%d, npcol=%d, NB=%d\n", nprow, npcol, nb);

	t_Grid grid;
	set_grid (&grid, ictxt, nprocs_mpi, myrank_mpi, myrow, mycol, nprow, npcol, nb);

	if (myrank_mpi==0)
		printf ("M\t\tGFlop/s (r)\t\tresid\n");

	for (i=start; i<=end; i+=step)
	{
		N = M = i;
		if (myrank_mpi==0)
			printf ("%d\t\t", M);
		/* 
		 * matrix parameter
		 */
		{
			// generate matrix
			distr_matrix (true,	 &A,    descA, M, N, &grid, &np_A, &nq_A);
			distr_matrix (false, &Aorg, NULL,  M, N, &grid, NULL,  NULL);	// for verification

			if (np_A*nq_A!=0)
				memcpy (Aorg, A, np_A*nq_A*sizeof(double));
		}
		

		/*
		 *	call ScaLAPACK LU 
		 */ 
		{
			int ipiv_len = numroc_( &M, &nb, &myrow, &izero, &nprow ) + nb;
			ipiv = (int *)malloc(ipiv_len*sizeof(int));
			memset (ipiv, 0, ipiv_len*sizeof(int));

			MPI_Barrier(MPI_COMM_WORLD);
			MPIt1 = MPI_Wtime();

			origpdgetrf_ (&M, &N, A, &ione, &ione, descA, ipiv, &info);

			MPIt2 = MPI_Wtime();
			checkerror(info, 0);
			double elapsed=MPIt2-MPIt1;
			MPI_Reduce( &elapsed, &MPIelapsed2, 1, MPI_DOUBLE, MPI_MAX, 0, MPI_COMM_WORLD);

			if (myrank_mpi==0)
			{
				GF2 = 2.0/3.0*M*M*M/MPIelapsed2/1e9;
				printf ("%f\t\t", GF2);
			}
			
			resid = verifyLU (Aorg, A, M, N, descA, ipiv, &grid);
			free (ipiv);
		}
			
		/*
		 * verify answers	
		 */ 
		{
			if (myrank_mpi == 0)
			{
				printf ("%e\n", resid);
			}
		}

		/*
		 * cleanup	
		 */ 

		if (np_A*nq_A!=0)	
		{
			free(A);
			free(Aorg);
		}

	}

	/*
	 * clean up
	 */
	fflush (stdout);
	Cblacs_gridexit( ictxt );
	MPI_Finalize();

	return 0;
}
