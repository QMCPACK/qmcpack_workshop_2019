#!/usr/bin/env python
import numpy
from pyscf.pbc import gto, scf, dft
from pyscf import gto as Mgto
from pyscf.pbc import df 
from pyscf.pbc import ao2mo
from pyscf.pbc import tools
from pyscf.pbc.tools.pbc import super_cell

#Example taken from QMCPACK tests/solids/diamondC_1x1x1-Gaussian_pp and modified to read
#our potential and basis. This assumes you have already downloaded the files into your current directory

nmp = [1, 1, 1] #Gamma point
cell = gto.Cell()
cell.a = '''
    3.37316115       3.37316115       0.00000000
    0.00000000       3.37316115       3.37316115
    3.37316115       0.00000000       3.37316115'''
cell.atom = '''  
   C        0.00000000       0.00000000       0.00000000
   C        1.686580575      1.686580575      1.686580575 
   ''' 
with open('C.cc-pVDZ.nwchem','r') as f:
    bas = f.read()
cell.basis={'C': Mgto.basis.parse(bas)}
with open('C.ccECP.nwchem','r') as f:
    ecp = f.read()
cell.ecp = {'C': Mgto.basis.parse_ecp(ecp)}
cell.unit='B'
cell.drop_exponent=0.1
cell.verbose = 5
cell.build()

supcell = super_cell(cell, nmp)
mydf = df.FFTDF(supcell)
mydf.auxbasis = 'weigend'
kpts=[]
mf = dft.RKS(supcell)
mf.xc = 'pbe'
mf.exxdiv = 'ewald'
mf.with_df = mydf
e_scf=mf.kernel()
ener = open('e_scf','w')
ener.write('%s\n' % (e_scf))
print 'e_scf',e_scf
