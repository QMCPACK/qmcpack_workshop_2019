#!/usr/bin/env python

from pyscf import gto,scf,dft
from urllib import urlretrieve
from PyscfToQmcpack import savetoqmcpack
import os

#Set the current working directory
cwd = os.getcwd()

#Obtain basis and ECP files from pseudopotentiallibrary.org
atom = "C"
pptype = "ccECP"
bastype= "cc-pVTZ"
pplib = "http://pseudopotentiallibrary.org/recipes"
basfile="{0}.{1}.nwchem".format(atom,bastype)
ecpfile="{0}.{1}.nwchem".format(atom,pptype)
xmlfile="{0}.{1}.xml".format(atom,pptype) #grab qmcpack xml file for later
urlretrieve("{0}/{1}/{2}/{3}".format(pplib,atom,pptype,basfile),
        filename=basfile)
urlretrieve("{0}/{1}/{2}/{3}".format(pplib,atom,pptype,ecpfile),
        filename=ecpfile)
urlretrieve("{0}/{1}/{2}/{3}".format(pplib,atom,pptype,xmlfile),
        filename=xmlfile)

#Initialize molecule object
mol = gto.Mole()
mol.atom = "{0} 0.0 0.0 0.0".format(atom)
with open(os.path.join(cwd,basfile)) as f:
    bas = f.read()
mol.basis = {atom: gto.basis.parse(bas)} 
with open(os.path.join(cwd,ecpfile)) as f:
    ecp = f.read()
mol.ecp = {atom: gto.basis.parse_ecp(ecp)}
mol.spin = 2
mol.charge = 0
mol.build()

#run HF and PBE
hf = scf.ROHF(mol)
hf.kernel()
pbe = dft.ROKS(mol)
pbe.xc = 'pbe'
pbe.kernel()

savetoqmcpack(mol,hf,title='{}.hf'.format(atom))
savetoqmcpack(mol,pbe,title='{}.pbe'.format(atom))

