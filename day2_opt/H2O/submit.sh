#!/bin/bash
#
# Job name: 
#SBATCH --job-name=rhf
#
# Account:
#SBATCH --account=co_chemqmc
#
# Partition:
#SBATCH --partition=savio
#
# QoS:
#SBATCH --qos=savio_lowprio
#
# Desire to be requeued if killed:
#SBATCH --requeue
#
# Request one node:
#SBATCH --nodes=4
#SBATCH --exclusive
#
# Wall clock limit:
#SBATCH --time=48:00:00
#
# Memory:
#SBATCH --mem-per-cpu=25000

job_subdir=qmcpack_jobs/robustness_test/H2O/state2/rhf_orbitals
home_dir=/global/home/users/spflores/$job_subdir
scratch_dir=/global/scratch/spflores/$job_subdir

qmcpack_exe=/global/home/users/spflores/qmcpack/build/bin/qmcpack

export OMP_NUM_THREADS=1

rm -rf $scratch_dir
mkdir -p $scratch_dir

cp -a $home_dir/sample* $home_dir/qmcpack.xml $home_dir/H.BFD.xml $home_dir/O.BFD.xml  $scratch_dir/

cd $scratch_dir

mpirun $qmcpack_exe qmcpack.xml > out

cp -a $scratch_dir/* $home_dir/

