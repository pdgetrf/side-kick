#	makefile for high-level threading LU	#

CC = mpicc 
FC = mpif77 

HOME = /home/ubuntu/sandbox/src

BLACSLIB =  $(HOME)/BLACS/LIB/blacsCinit_MPI-LINUX-0.a  $(HOME)/ext_libs/BLACS/LIB//blacsF77init_MPI-LINUX-0.a  $(HOME)/ext_libs/BLACS/LIB//blacs_MPI-LINUX-0.a

MKLROOT   = /home/ubuntu/sandbox/src/ext_libs/lapack-3.3.1
FASTBLASLIB = -L$(MKLROOT) -llapack -lblas
#FASTBLASLIB = -L$(MKLROOT)/lib/intel64 -Wl,--start-group -lscalapack $(BLACSLIB)  -lmkl_intel_lp64 -lmkl_gnu_thread -lmkl_core -Wl,--end-group -fopenmp
GPULIB = 

CUDADIR   = 
INC       = -I$(CUDADIR)/include 


CFLAGS = -Wall -I$(HOME)/ext_libs/scalapack-1.8.0/PBLAS/SRC -I$(HOME)/ext_libs/scalapack-1.8.0/PBLAS/SRC/PTOOLS -I/home/ubuntu/lib/mpich2/include
#CFLAGS += -DTIMING
FFLAGS =  -fsecond-underscore

LDFLAGS =  -L$(HOME)/ext_libs/lapack-3.3.1\
		   -L$(HOME)/ext_libs/scalapack-1.8.0 \
		   -L$(HOME)/ext_libs/lapack-3.3.0 \
		   -L$(HOME)/ext_libs/BLACS/LIB/ 


LINKLIB =   lu_test.o pdgeqrrv.o pdmatgen.o pmatgeninc.o pdlaprnt.o orig_pdgetrf.o util_ft.o pdgetrrv.o \
			$(FASTBLASLIB)

PROG = lu_test.x

$(PROG) : lu_test.o pdgeqrrv.o pdmatgen.o pmatgeninc.o pdlaprnt.o util_ft.o orig_pdgetrf.o pdgetrrv.o 
	$(FC) -o $(PROG) $(CFLAGS) $(LDFLAGS) $(LINKLIB) 

.c.o:
	$(CC) -c -O3 $(DEBUG) $(CFLAGS)  $*.c

.cpp.o:
	$(CC) -c -O3 $(DEBUG) $(CFLAGS)  $*.cpp

.f.o:
	$(FC) -c -O3 $(DEBUG) $(FFLAGS)  $*.f 

clean:
	rm *.o *.x
