############################################################################
#
#  Program:         ScaLAPACK
#
#  Module:          SLmake.inc
#
#  Purpose:         Top-level Definitions
#
#  Creation date:   February 15, 2000
#
#  Modified:
#
#  Send bug reports, comments or suggestions to scalapack@cs.utk.edu
#
############################################################################
#
SHELL         = /bin/sh
#
#  The complete path to the top level of ScaLAPACK directory, usually
#  $(HOME)/SCALAPACK
#
home          = /home/ubuntu/lib/scalapack-1.8.0
#
#  The platform identifier to suffix to the end of library names
#
PLAT          = LINUX
#
#  BLACS setup.  All version need the debug level (0 or 1),
#  and the directory where the BLACS libraries are
#
BLACSDBGLVL   = 0
BLACSdir      = /home/ubuntu/lib/BLACS/LIB
#
#  MPI setup; tailor to your system if using MPIBLACS
#  Will need to comment out these 6 lines if using PVM
#
USEMPI        = -DUsingMpiBlacs
SMPLIB        = /usr/local/lib/libmpich.a
BLACSFINIT    = $(BLACSdir)/blacsF77init_MPI-LINUX-0.a
BLACSCINIT    = $(BLACSdir)/blacsCinit_MPI-LINUX-0.a
BLACSLIB      = $(BLACSdir)/blacs_MPI-LINUX-0.a
TESTINGdir    = $(home)/TESTING

#
#  PVMBLACS setup, uncomment next 6 lines if using PVM
#
#USEMPI        =
#SMPLIB        = $(PVM_ROOT)/lib/$(PLAT)/libpvm3.a
#BLACSFINIT    =
#BLACSCINIT    =
#BLACSLIB      = $(BLACSdir)/blacs_PVM-$(PLAT)-$(BLACSDBGLVL).a
#TESTINGdir    = $(HOME)/pvm3/bin/$(PLAT)

CBLACSLIB     = $(BLACSCINIT) $(BLACSLIB) $(BLACSCINIT)
FBLACSLIB     = $(BLACSFINIT) $(BLACSLIB) $(BLACSFINIT)

#
#  The directories to find the various pieces of ScaLapack
#
PBLASdir      = $(home)/PBLAS
SRCdir        = $(home)/SRC
TESTdir       = $(home)/TESTING
PBLASTSTdir   = $(TESTINGdir)
TOOLSdir      = $(home)/TOOLS
REDISTdir     = $(home)/REDIST
REDISTTSTdir  = $(TESTINGdir)
#
#  The fortran and C compilers, loaders, and their flags
#
F77           = mpif77
CC            = mpicc
NOOPT         = -fsecond-underscore
F77FLAGS      =  -O3 $(NOOPT) 
CCFLAGS       = -O4
SRCFLAG       =
F77LOADER     = $(F77)
CCLOADER      = $(CC)
F77LOADFLAGS  = -L/home/du/lib/gcc/lib/ -lgfortran 
CCLOADFLAGS   = 
#
#  C preprocessor defs for compilation 
#  (-DNoChange, -DAdd_, -DUpCase, or -Df77IsF2C)
#
CDEFS         = -Df77IsF2C -DNO_IEEE $(USEMPI)
#
#  The archiver and the flag(s) to use when building archive (library)
#  Also the ranlib routine.  If your system has no ranlib, set RANLIB = echo
#
ARCH          = ar
ARCHFLAGS     = cr
RANLIB        = ranlib
#
#  The name of the libraries to be created/linked to
#
SCALAPACKLIB  = $(home)/libscalapack.a
BLASLIB       = /home/ubuntu/lib/lapack-3.3.1/libblas.a
LAPACKLIB     = /home/ubuntu/lib/lapack-3.3.1/liblapack.a
#
PBLIBS        = $(SCALAPACKLIB) $(FBLACSLIB) $(LAPACKLIB) $(BLASLIB) $(SMPLIB)
PRLIBS        = $(SCALAPACKLIB) $(CBLACSLIB) $(SMPLIB)
RLIBS         = $(SCALAPACKLIB) $(FBLACSLIB) $(CBLACSLIB) $(LAPACKLIB) $(BLASLIB) $(SMPLIB)
LIBS          = $(PBLIBS)
