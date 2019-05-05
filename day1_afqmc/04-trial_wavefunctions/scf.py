#!/usr/bin/env python

import sys
import h5py
import scipy.linalg
import numpy
from pyscf import gto, scf, mcscf, fci, lib
from afqmctools.utils.pyscf_utils import load_from_pyscf_chk_mol
from afqmctools.utils.qmcpack_utils import write_skeleton_input
from afqmctools.utils.linalg import get_ortho_ao_mol
from afqmctools.hamiltonian.mol import write_hamil_mol
from afqmctools.wavefunction.mol import (
        write_nomsd_wfn,
        write_phmsd_wfn,
        gen_multi_det_wavefunction
        )

# 1. We will first generate a fake 2 determinant NOMSD trial wavefunction
# expansion made up of the RHF solutions replicated twice. This is nonsense but
# it's just to demonstrate how to write things.
mol = gto.M(atom=[['N', (0,0,0)], ['N', (0,0,3.0)]],
            basis='cc-pvdz',
            unit='Bohr')
nalpha, nbeta = mol.nelec
rhf = scf.RHF(mol)
rhf.chkfile = 'scf.rhf.chk'
rhf.kernel()
# Transformation matrix to ortho AO basis.
X = get_ortho_ao_mol(mol.intor('int1e_ovlp_sph'))
Xinv = scipy.linalg.inv(X)
with h5py.File('scf.rhf.chk') as fh5:
    fh5['scf/orthoAORot'] = X

# a. Generate Hamiltonian in ortho AO basis.
scf_data = load_from_pyscf_chk_mol('scf.rhf.chk')
ortho_ao = True
write_hamil_mol(scf_data, 'hamil.h5', 1e-5, verbose=True, ortho_ao=ortho_ao)

# b. Fake a two determinant trial wavefunction.

wfn = numpy.zeros((2,rhf.mo_coeff.shape[1],nalpha+nbeta))
Coao = numpy.dot(Xinv, rhf.mo_coeff)
wfn[0,:,:nalpha] = Coao[:,:nalpha]
wfn[0,:,nalpha:] = Coao[:,:nbeta]
wfn[1,:,:nalpha] = Coao[:,:nalpha]
wfn[1,:,nalpha:] = Coao[:,:nbeta]
c = 1.0/numpy.sqrt(2)
write_nomsd_wfn('wfn.nomsd.dat', wfn, nalpha, True, coeffs=[c,c])
write_skeleton_input('afqmc.nomsd.xml', 'hamil.h5', series=0, blocks=100,
                     wfn_file='wfn.nomsd.dat')

# 2. Write CASSCF wavefunction.
# a. Perform CASSCF calculation, this replicates the calculations from
# J. Chem. Phys. 127, 144101 (2007).
# They find a CASSCF energy of -108.916484 Ha, and a ph-AFQMC energy of
# -109.1975(6) Ha with a 97 determinant CASSCF trial.
M = 12
N = 6
mc = mcscf.CASSCF(rhf, M, N)
mc.chkfile = 'casscf.chk'
mc.kernel()
nalpha = 3
nbeta = 3
# Extract ci expansion in the form of a tuple: (coeff, occ_a, occ_b).
# Note the tol param which will return wavefunction elements with abs(ci) > tol.
occs = fci.addons.large_ci(mc.ci, M, (nalpha,nbeta),
                           tol=0.02, return_strs=False)
# b. Generate Hamiltonian.
# Passing 'mccsf' will tell helper function to read mo_coeff/mo_occ from mcscf
# group in checkpoint file. We will rotate the integrals by mc.mo_coeff.
scf_data = load_from_pyscf_chk_mol('casscf.chk', 'mcscf')
write_hamil_mol(scf_data, 'hamil.casscf.h5', 1e-5, verbose=True)
# c. Write PHMSD wavefunction to file.
write_phmsd_wfn('wfn.phmsd.dat', occs, mc.mo_coeff.shape[-1], ncore=mc.ncore)
# d. Generate QMCPACK input file.
write_skeleton_input('afqmc.phmsd.xml', 'hamil.casscf.h5',
                     wfn_file='wfn.phmsd.dat', series=1,
                     blocks=100)
