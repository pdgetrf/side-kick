/*
 * init BLACS 
 */
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
