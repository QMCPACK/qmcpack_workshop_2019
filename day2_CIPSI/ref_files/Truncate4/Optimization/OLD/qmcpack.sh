#!/bin/bash

cwd=`pwd`
queue=default
#queue=Q.long
acct=Catalyst
#acct=QMCSim
time=120



nodes=256
nthreads=32
mode=c1


bin=qmcpack
bindir=/home/abenali/qmcpack-github/build_Clang++11_real_SoA/bin

intemplate=Opt
title=bgq.${intemplate}.-${mode}_p${nodes}x${nthreads}.`date +"%m-%d-%y_%H%M"`

qmcin=${intemplate}.xml
qmcout=${title}

qsub -A $acct -q $queue -n $nodes -t $time -O ${qmcout} --mode $mode --env BG_SHAREDMEMSIZE=32:OMP_NUM_THREADS=${nthreads} $bindir/$bin $qmcin

