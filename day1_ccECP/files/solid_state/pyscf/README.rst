ccECP Example 2: Solid State Example with PySCF
===============================================

To do solid state gaussian basis set calculations, in particular for PySCF, we simply need to download our basis and ECP

.. code-block:: bash

  wget http://pseudopotentiallibrary.org/recipes/C/ccECP/C.ccECP.nwchem
  wget http://pseudopotentiallibrary.org/recipes/C/ccECP/C.cc-pVDZ.nwchem
  wget http://pseudopotentiallibrary.org/recipes/C/ccECP/C.cc-pVTZ.nwchem
  wget http://pseudopotentiallibrary.org/recipes/C/ccECP/C.cc-pVQZ.nwchem
  
We will look at the diamond primitive cell, at the Gamma point

In the diamond.py file provided, we set up the diamond calculation using our 

.. code-block:: python

  #!/usr/bin/env python
  import numpy
  from pyscf.pbc import gto, scf, dft
  from pyscf import gto as Mgto
  from pyscf.pbc import df 
  from pyscf.pbc import ao2mo
  from pyscf.pbc import tools
  from pyscf.pbc.tools.pbc import super_cell

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
  
Details about how to perform PySCF calculations for the solid state with PySCF will be covered later, the important point here is that we simply have to download the files and use them. 
The key difference is to use the PBC gto to create the simulation cell, and the molecular gto object to read/parse the basis sets and ECPs. 
Another import command is the command

.. code-block:: python
  
  cell.drop_exponent=0.1
  
In PBC, gaussian basis functions with diffuse exponents can lead to linear dependence issues.
Therefore, we drop these exponents in hopes that it converges. 

Executing this should result in an energy of 

.. code-block:: bash

  cycle= 6 E= -10.2576220435048  delta_E= -2.06e-11  |g|= 3.11e-08  |ddm|= 9.44e-05
      CPU time for cycle= 6     10.04 sec, wall time      1.28 sec
    HOMO = 0.568560724603697  LUMO = 0.759576308177147
    mo_energy =
  [-0.25053649  0.5685601   0.56856072  0.56856072  0.75957631  0.75957688
   0.75957688  1.06964562  1.51401349  1.51401349  1.87304042  1.87304196
   1.87304196  2.18438083  2.33156371  2.33156664  2.33156664  3.26394757
   3.26394895  3.26394895  3.29111608  3.29111608  4.34193724  4.34193752
   4.34193752  7.75737744]
  nelec by numeric integration = 8.00000000000738
     CPU time for vxc      9.87 sec, wall time      1.26 sec
      CPU time for vj      0.00 sec, wall time      0.00 sec
  E1 = 4.760266874094651  Ecoul = 1.5275019325330996  Exc = -3.7697236225455004
  Ewald components = 7.04197374062218e-32, -52.6325485976164, 39.8568813700294
  Extra cycle  E= -10.2576220435047  delta_E= 5.33e-15  |g|= 2.02e-08  |ddm|= 3.9e-07
     CPU time for scf_cycle    255.76 sec, wall time     32.74 sec
     CPU time for SCF    255.82 sec, wall time     32.75 sec
  converged SCF energy = -10.2576220435047
  e_scf -10.25762204350475

Since we have already downloaded larger basis sets, we can check to see if our total energy is converged. 
Simply we change the basis by

.. code-block:: python

    with open('C.cc-pVTZ.nwchem','r') as f:
     bas = f.read()
     
and rerun. You should find that this converges to 

.. code-block:: bash

  cycle= 6 E= -10.2757568005126  delta_E= -6.39e-12  |g|= 7.35e-08  |ddm|= 2.28e-05
      CPU time for cycle= 6     12.55 sec, wall time      1.63 sec
    HOMO = 0.560619105567743  LUMO = 0.752327551488989
    mo_energy =
  [-0.26228307  0.56061841  0.56061911  0.56061911  0.75232755  0.75232813
   0.75232813  1.05912726  1.31415562  1.48883927  1.48883927  1.50810892
   1.50810897  1.50810897  1.92170189  2.29397443  2.29397635  2.29397635
   3.01529881  3.01529928  3.01529928  3.17043592  3.17043592  3.37148525
   3.37148525  3.37148526  3.57685493  3.57686105  3.57686105  4.19259462
   4.19259497  4.19259497  4.52282835  4.52282943  4.52282943  4.7263293
   4.72633038  4.72633038  4.72900728  4.73763887  4.73763887  4.98049311
   4.98049311  5.02180302  5.02180306  5.02180306  5.32943354  6.11947967
   6.11948787  6.11948787  6.14681739  6.14681897  6.14681897  8.12022924
   8.12024412  8.12024414 12.39618712 16.06790218]
  nelec by numeric integration = 7.99999999999595
     CPU time for vxc     12.45 sec, wall time      1.65 sec
     CPU time for vj      0.03 sec, wall time      0.00 sec
  E1 = 4.776608302643451  Ecoul = 1.4688129667694838  Exc = -3.745510842338502
  Ewald components = 7.04197374062218e-32, -52.6325485976164, 39.8568813700294
  Extra cycle  E= -10.2757568005126  delta_E=    0  |g|= 3.34e-08  |ddm|= 2.5e-06
     CPU time for scf_cycle    521.84 sec, wall time     77.01 sec
     CPU time for SCF    521.91 sec, wall time     77.02 sec
  converged SCF energy = -10.2757568005126
  e_scf -10.275756800512568

We find a significant decrease in the total energy by roughly 18 mHa.

We can attempt to go further by trying the VQZ basis, but 

.. code-block:: bash

  WARN: Singularity detected in overlap matrix.  Integral accuracy may be not enough.
        You can adjust  cell.precision  or  cell.rcut  to improve accuracy.  Recommended values are
       cell.precision = 3.7e-10  or smaller.                             
        cell.rcut = 23.31  or larger.
                                                                              
  cond(S) = 270615143735.09268                      
                                                                           
  WARN: Singularity detected in overlap matrix (condition number = 2.71e+11). SCF may be inaccurate and hard to converge.
                                                                                  

This indicates some of the issues that can arise for gaussian basis sets in PBC.
If your calculations are problematic, the minimum exponent may need to be increased, or the entire basis set may need to be reoptimized.
If you decide to optimize your own basis, a number of issues should be considered:

- The contracted basis functions should be tailored to your specific basis. These can generally be optimized for the atom. A good rule of thumb is to optimize the atomic state somewhere in between the ground state and the oxidation state of the atom in the solid. 
- The primitive, uncontracted exponents can be taken from existing basis sets used in solids. A number of basis sets with useful primitive exponents can be found at `CRYSTAL BASIS SET <http://www.crystal.unito.it/basis-sets.php>`_ or from `Crystal Resources Page <https://www.tcm.phy.cam.ac.uk/~mdt26/crystal.html>`_. If these are insufficient, you may have to construct your own. 
- If you need to generate your own primitive exponents, this should be optimized for your problem. Try a molecular system with bonding similar to your solid state system to optimize the primitives, and then use test them in your application. 
- A number of documents describing in detail how to optimize solid state gaussian basis sets can be found at `http://qwalk.org/tarballs/tutorial/basis_sets.pdf <http://qwalk.org/tarballs/tutorial/basis_sets.pdf>`_ and `https://www.tcm.phy.cam.ac.uk/~mdt26/basis_sets/basis_sets_2000.ps <https://www.tcm.phy.cam.ac.uk/~mdt26/basis_sets/basis_sets_2000.ps>`_
