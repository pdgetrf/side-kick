#	makefile for high-level threading LU	#

CC = mpicc 
FC = mpif77 

HOME = /home/ubuntu

BLACSLIB =  $(HOME)/lib/BLACS/LIB/blacsCinit_MPI-LINUX-0.a  $(HOME)/lib/BLACS/LIB/blacsF77init_MPI-LINUX-0.a  $(HOME)/lib/BLACS/LIB/blacs_MPI-LINUX-0.a

MKLROOT   = /home/ubuntu/sandbox/src/lib/lapack-3.3.1
FASTBLASLIB = -L$(MKLROOT) -lscalapack $(BLACSLIB) -llapack -lblas
#FASTBLASLIB = -L$(MKLROOT)/lib/intel64 -Wl,--start-group -lscalapack $(BLACSLIB)  -lmkl_intel_lp64 -lmkl_gnu_thread -lmkl_core -Wl,--end-group -fopenmp

CUDADIR   = 
INC       = -I$(CUDADIR)/include


CFLAGS = -Wall -I$(HOME)/lib/scalapack-1.8.0/PBLAS/SRC -I$(HOME)/lib/scalapack-1.8.0/PBLAS/SRC/PTOOLS -I/home/ubuntu/lib/mpich2/include
#CFLAGS += -DTIMING
FFLAGS =  -fsecond-underscore

LDFLAGS =  -L$(HOME)/lib/lapack-3.3.1\
		   -L$(HOME)/lib/scalapack-1.8.0 \
		   -L$(HOME)/lib/BLACS/LIB/ 


LINKLIB =   qr_test.o pdgeqrrv.o pdmatgen.o pmatgeninc.o pdlaprnt.o orig_pdgeqrf.o util_ft.o $(FASTBLASLIB) $(GPULIB)

PROG = qr_test.x

$(PROG) : qr_test.o pdgeqrrv.o pdmatgen.o pmatgeninc.o pdlaprnt.o util_ft.o orig_pdgeqrf.o
	$(FC) -o $(PROG) $(CFLAGS) $(LDFLAGS) $(LINKLIB) 

.c.o:
	$(CC) -c -O3 $(DEBUG) $(CFLAGS)  $*.c

.cpp.o:
	$(CC) -c -O3 $(DEBUG) $(CFLAGS)  $*.cpp

.f.o:
	$(FC) -c -O3 $(DEBUG) $(FFLAGS)  $*.f 

clean:
	rm *.o *.x
