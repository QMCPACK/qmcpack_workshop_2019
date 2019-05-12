#!/usr/bin/env python

from pyscf import gto
from pyscf import scf, dft, df

mol = gto.Mole()
mol.verbose = 5
mol.atom =''' 
  H             0.00000000       0.75720000      -0.46920000
  H             0.00000000      -0.75720000      -0.46920000
  O             0.00000000       0.00000000       0.11730000
 '''
mol.unit='A'
mol.basis = 'cc-pvtz'
#mol.pseudo = 'bfd-vtz'
mol.spin=0 #Value of S where the spin multiplicity is 2S+1
mol.build()



#Hartree Fock
mf = scf.ROHF(mol)

#DFT
#mf = dft.ROKS(mol)
#mf.xc ='b3lyp' 

e_scf=mf.kernel()

#Section for QMCPACK
title="H2O_AE_HF"
from PyscfToQmcpack import savetoqmcpack
savetoqmcpack(mol,mf,title=title)

