#!/bin/bash

#
# Setup script to install QMCPACK, Quantum Espresso (QE/PWSCF), PySCF, Quantum Package (QP),
# and workshop files for QMCPACK 2019 workshop https://qmc2019.ornl.gov/
#
# Assumes a vanilla Ubuntu 18.04 LTS or similar and x86 architecture
# Script is safely rerunnable
# 
echo -- START `date`
sudo apt-get -y update
sudo apt-get -y install cmake g++ gfortran libboost-dev libhdf5-dev libxml2-dev 

# Slow/unoptimized BLAS and LAPACK for expedient linking with QP and PySCF
#sudo apt-get -y install libblas-dev liblapack-dev
sudo apt-get -y install libopenblas-dev

if [ ! -e $HOME/apps ]; then
    mkdir $HOME/apps
fi

# QP install ahead of other apps
sudo apt-get -y install ninja-build m4 unzip
sudo apt-get -y install python # QP dependencies assume python availability
cd $HOME/apps
if [ ! -e qp2 ]; then
    echo --- Building QP2 `date`
    CC=gcc
    CXX=g++
    F90=gfortran
    F95=gfortran
    F77=gfortran
    git clone https://github.com/QuantumPackage/qp2.git 
    cd qp2
    ./configure -i all
# Default 
#    ./configure -c config/gfortran.cfg
# Workaround for AWS     
    sed 's/-Ofast -march=native/-O3 -march=broadwell/g' config/gfortran.cfg >config/gfortran_safe.cfg
    ./configure -c config/gfortran_safe.cfg
# Failed attempt to use MKL. Is unreliable.    
#    sed -e 's/-lblas -llapack/-L\/opt\/intel\/compilers_and_libraries_2019.3.199\/linux\/mkl\/lib\/intel64 -Wl,--no-as-needed -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core -liomp5 -lpthread -lm -ldl/g' config/gfortran.cfg >config/gfortran_mkl.cfg
#    ./configure -c config/gfortran_mkl.cfg
    source quantum_package.rc
    ninja
    cd plugins
    git clone https://github.com/QuantumPackage/QMCPACK_ff.git qmcpack
    cd ../
    qp_plugins install qmcpack
    sed -i s/"  read_wf = .False."/"  \!read_wf = .False."/g    src/determinants/determinants.irp.f
    ninja
fi

echo --- Intel files setup `date`
# Setup Intel MKL and MPI
# Instructions from https://software.intel.com/en-us/articles/installing-intel-free-libs-and-python-apt-repo
wget https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
sudo apt-key add GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
rm -f GPG-PUB-KEY-INTEL-SW-PRODUCTS-2019.PUB
#Full Intel MKL+Python products 
sudo wget https://apt.repos.intel.com/setup/intelproducts.list -O /etc/apt/sources.list.d/intelproducts.list 
#MKL:  
#sudo sh -c 'echo deb https://apt.repos.intel.com/mkl all main > /etc/apt/sources.list.d/intel-mkl.list'  
#Intel MPI
#sudo sh -c 'echo deb https://apt.repos.intel.com/mpi all main > /etc/apt/sources.list.d/intel-mpi.list'
sudo apt-get -y update
sudo apt-get -y install intel-mkl-2019.3-062 #Be patient
sudo apt-get -y install intel-mpi-2019.3-062 #Be patient

echo --- Tools `date`
# Nice to have tools
sudo apt-get -y install emacs-nox
sudo apt-get -y install gnuplot

# Setup Intel MKL variables, path
source /opt/intel/mkl/bin/mklvars.sh intel64
# Setup Intel MPI variables, path
source /opt/intel/impi/2019.3.199/intel64/bin/mpivars.sh


if [ ! -e $HOME/apps ]; then
    mkdir $HOME/apps
fi
cd $HOME/apps

# HDF5 installation
if [ ! -e hdf5-hdf5-1_10_5-gcc-impi/lib/libhdf5.a ]; then   
echo --- Installing HDF5 `date`
    wget https://github.com/live-clones/hdf5/archive/hdf5-1_10_5.tar.gz
    tar xvf hdf5-1_10_5.tar.gz
    #XXX rm -f hdf5-1_10_5.tar.gz
    mkdir hdf5-hdf5-1_10_5-gcc-impi
    cd hdf5-hdf5-1_10_5-gcc-impi/
    INSTALLDIR=`pwd`
    echo INSTALLDIR=$INSTALLDIR
    CC=mpigcc FC=mpif90 ../hdf5-hdf5-1_10_5/configure --enable-shared --enable-parallel --enable-fortran  --prefix=$INSTALLDIR >&configure.out
    make >&make.out
    make install 
    cd ..
fi

# Requirements for full NEXUS demo:
sudo apt-get -y install python-pip
sudo apt-get -y install python-numpy python-scipy python-matplotlib python-pydot python-h5py

CC="mpigcc" HDF5_MPI="ON" HDF5_DIR=$HOME/apps/hdf5-hdf5-1_10_5-gcc-impi pip install --user --no-binary=h5py h5py

pip install --user spglib
pip install --user seekpath

pip install --user mpi4py # Maybe for AFQMC demo?

# QMCPACK and patched QE
echo --- QMCPACK and QE setup
cd $HOME/apps
if [ ! -e qmcpack ]; then
    mkdir qmcpack
fi
cd qmcpack
if [ ! -e qmcpack ]; then
    git clone https://github.com/QMCPACK/qmcpack.git
else
    cd qmcpack
    git pull
    cd ..
fi

# QE
if [ ! -e $HOME/apps/qe-6.4/bin/pw.x ]; then
echo --- Patching and Building QE `date`
    cd $HOME/apps/qmcpack/qmcpack/external_codes/quantum_espresso/
    ./download_and_patch_qe6.4.sh
    cd qe-6.4
    ./configure  CC=mpigcc MPIF90=mpif90 F77=mpif77 --with-scalapack=intel --with-hdf5=$HOME/apps/hdf5-hdf5-1_10_5-gcc-impi  >&configure.out
    make pw >&make_pw.out
    make pwall >&make_pwall.out
    if [ -e $HOME/apps/qe-6.4 ]; then
	rm -r -f $HOME/apps/qe-6.4
    fi
    cd ..
    mv qe-6.4 $HOME/apps
    cd $HOME/apps
fi


cd $HOME/apps/qmcpack
if [ ! -e build/bin/qmcpack ]; then
echo --- Building QMCPACK `date`
rm -r -f build
mkdir build
cd build
cmake -DCMAKE_CXX_COMPILER=mpigxx -DCMAKE_C_COMPILER=mpigcc -DBUILD_LMYENGINE_INTERFACE=1 -DQMC_MPI=1 -DENABLE_MKL=1 -DMKL_ROOT=$MKLROOT -DHDF5_ROOT=$HOME/apps/hdf5-hdf5-1_10_5-gcc-impi -DQE_BIN=$HOME/apps/qe-6.4/bin -DCMAKE_C_FLAGS=-march=broadwell -DCMAKE_CXX_FLAGS=-march=broadwell ../qmcpack/ >&cmake.out
make -j 16 >&make.out
ctest -R deterministic >& ctest.out
cat ctest.out
cd ..
fi

if [ ! -e build_complex/bin/qmcpack ]; then
echo --- Building QMCPACK Complex `date`
rm -r -f build_complex
mkdir build_complex
cd build_complex
cmake -DCMAKE_CXX_COMPILER=mpigxx -DCMAKE_C_COMPILER=mpigcc -DQMC_COMPLEX=1 -DBUILD_AFQMC=1 -DBUILD_LMYENGINE_INTERFACE=1 -DQMC_MPI=1  -DENABLE_MKL=1 -DMKL_ROOT=$MKLROOT -DHDF5_ROOT=$HOME/apps/hdf5-hdf5-1_10_5-gcc-impi -DQE_BIN=$HOME/apps/qe-6.4/bin -DCMAKE_C_FLAGS=-march=broadwell -DCMAKE_CXX_FLAGS=-march=broadwell ../qmcpack/ >&cmake.out
make -j 16 >&make.out
ctest -R deterministic >& ctest.out
cat ctest.out
cd ../build/bin
ln -sf ../../build_complex/bin/qmcpack qmcpack_complex
cd ..
fi


# PySCF
cd $HOME/apps
if [ ! -e pyscf-1.6.1 ]; then
echo --- Building PySCF 
    if [ ! -e v1.6.1.tar.gz ]; then    
	wget https://github.com/pyscf/pyscf/archive/v1.6.1.tar.gz
    fi
    tar xvf v1.6.1.tar.gz
    cd pyscf-1.6.1
    cd pyscf/lib
    if [ -e build ]; then
	rm -r -f build
    fi
    mkdir build
    cd build
# Configure with slow system BLAS. MKL is problematic (LD_PRELOAD issues, https://sunqm.github.io/pyscf/install.html#using-optimized-blas)
    cmake ..
#    cmake -DBLA_VENDOR=Intel10_64lp_seq ..
    make
    cd ..
fi


cd $HOME
echo --- Shell setup `date`
HAVESETUP=`grep -c START-QMCPACK-RELATED $HOME/.bashrc`
if  [ $HAVESETUP -eq 0 ]; then
    echo --- Modifying .bashrc to add PATHs
cat >>$HOME/.bashrc <<EOF
# START-QMCPACK-RELATED
# Setup Intel MKL variables, path
source /opt/intel/mkl/bin/mklvars.sh intel64
# Setup Intel MPI variables, path
source /opt/intel/impi/2019.3.199/intel64/bin/mpivars.sh
# QMCPACK and NEXUS
export PATH=\$HOME/apps/qmcpack/build/bin:\$PATH
export PATH=\$HOME/apps/qmcpack/qmcpack/nexus/bin:\$PATH
export PYTHONPATH=\$HOME/apps/qmcpack/qmcpack/nexus/lib:\$PYTHONPATH
export PYTHONPATH=\$HOME/apps/qmcpack/qmcpack/utils/afqmctools:\$PYTHONPATH
# QE
export PATH=\$HOME/apps/qe-6.4/bin:\$PATH
# PySCF
export PYTHONPATH=\$HOME/apps/pyscf-1.6.1:\$PYTHONPATH
export PYTHONPATH=\$HOME/apps/qmcpack/qmcpack/src/QMCTools:\$PYTHONPATH
# QP
source \$HOME/apps/qp2/quantum_package.rc
# END-QMCPACK-RELATED
EOF
else
    echo --- .bashrc already contains setup information. Not modifying.
fi
# Add setup info to current shell for convenience
# Setup Intel MKL variables, path
#source /opt/intel/mkl/bin/mklvars.sh intel64
# Setup Intel MPI variables, path
#source /opt/intel/impi/2019.3.199/intel64/bin/mpivars.sh
# QMCPACK and NEXUS
export PATH=$HOME/apps/qmcpack/build/bin:$PATH
export PATH=$HOME/apps/qmcpack/qmcpack/nexus/bin:$PATH
export PYTHONPATH=$HOME/apps/qmcpack/qmcpack/nexus/lib:$PYTHONPATH
# QE
export PATH=$HOME/apps/qe-6.4/bin:$PATH
# PySCF
export PYTHONPATH=$HOME/apps/pyscf-1.6.1:$PYTHONPATH
export PYTHONPATH=$HOME/apps/qmcpack/qmcpack/src/QMCTools:$PYTHONPATH
# QP
source $HOME/apps/qp2/quantum_package.rc

echo --- Workshop files `date`
# Workshop files
cd $HOME
if [ ! -e qmcpack_workshop_2019 ]; then
    git clone https://github.com/QMCPACK/qmcpack_workshop_2019.git
else
    cd qmcpack_workshop_2019
    git pull
    cd ..
fi
echo -- END `date`

