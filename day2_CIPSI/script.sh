#!/bin/bash

#source QP
source $HOME/apps/qp2/quantum_package.rc

#Create ezfio
 qp_create_ezfio H2O.xyz -b "O:cc-pcvtz |H:cc-pvtz"

#run HF
qp_run scf H2O.ezfio | tee H2O-scf.out

#run small fci to generate nat orbitals
echo "50000" > H2O.ezfio/determinants/n_det_max
qp_run fci H2O.ezfio | tee H2O-fci0.out
qp_run print_e_conv H2O.ezfio

#Save Natural Orbitals
qp_run save_natorb H2O.ezfio 

#run fci
echo "100000" > H2O.ezfio/determinants/n_det_max
qp_run fci H2O.ezfio | tee H2O-fci.out
qp_run print_e_conv H2O.ezfio

#WF Truncation
for i in 4 5 6 8
do

mkdir Truncate$i
cp -r H2O.ezfio  Truncate$i/.
echo "1.0e-0$i" > Truncate$i/H2O.ezfio/qmcpack/ci_threshold
cd Truncate$i 
qp_run truncate_wf_spin H2O.ezfio | tee H2O-Tr$i.out
qp_run pt2 H2O.ezfio | tee H2O-Tr$i.pt2.out





#save for Qmcpack
qp_run save_for_qmcpack H2O.ezfio > H2O-Tr$i

#Generate QMC Inputs
convert4qmc -QP H2O-Tr$i -production -hdf5 -addCusp


cd ../

done



 
