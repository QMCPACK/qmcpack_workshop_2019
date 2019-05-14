PBC Example: Carbon diamond in a 2x1x1 supercell using HF trial wavefunction and a 2x1x1 Kpoint mesh. 
====================

In this example we will go through the basic steps necessary to
generate DMC input from a pyscf calculation on a periodic Boundary Condition 
Carbon diamond Solid using Kpoints, HF and BFD ECPs.

The pyscf input  is given dft-inputs directory as (diamondC_2x1x1.py).  

.. code-block:: python
  
      import numpy as np
      from pyscf.pbc import gto, scf, dft
      from pyscf.pbc import df

      cell = gto.Cell()
      cell.a             = '''
                     3.37316115   3.37316115    0.000000
                     0.000000   3.37316115   3.37316115
                     3.37316115   0.000000   3.37316115
                     '''
       cell.dimension     = 3
       cell.basis         = 'bfd-vdz'
       cell.ecp           = 'bfd'
       cell.unit          = 'B'
       cell.atom          = '''
                            C     0.000000   0.00000000   0.00000000
                            C    1.68658058   1.68658058   1.68658058
                            '''
       cell.drop_exponent = 0.1
       cell.verbose       = 5
       cell.charge        = 0
       cell.spin          = 0
       cell.build()
      
       
       sp_twist=[0.0, 0.0, 0.0]
       
       kpts = [[ 0.0,  0.0, 0.0],
        [0.46567485,  0.46567485, -0.46567485]]
      
       supcell=cell
       mydf = df.FFTDF(supcell,kpts)
       mydf.auxbasis = 'weigend'
       mf = scf.KRHF(supcell,kpts).density_fit()
        
       mf.exxdiv = 'ewald'
       mf.with_df = mydf
       e_scf=mf.kernel()
      
       ener = open('e_scf','w')
       ener.write('%s\n' % (e_scf))
       print('e_scf',e_scf)
       ener.close()
      
       title="S2-twist1"
       from PyscfToQmcpack import savetoqmcpack
       savetoqmcpack(cell,mf,title=title,kpts=kpts,sp_twist=sp_twist)




Multiple important point in this input!
1) cell.drop_exponent = 0.1
This flag tells us that every exponent in the basis set smaller than 0.1 will be removed. This means that the accuracy of the basisset is reduced
The reason for doing so is to reduce the number of periodic images required to use when computing the Coulomb potential, Such smal exponents lead 
to an extensive number of periodic images due to the fact that the basis set from BFD were not built for PBC systems. Ideally a convergence of the 
energy with the size of the cutoff in exponent size should be conducted. 
For a complete list of options refer to Pyscf Manual in https://sunqm.github.io/pyscf/dft.html#

In this example we are using the ECP from Burkatzki, Fillipi and Dolg for O and H with their 
corresponding VTZ basis set. They can be found in the quantum chemistry format 
in http://www.burkatzki.com/pseudos/index.2.html

2) In this case, we use the super twist 0,0,0 with a super cell in 2x1x1. The correct coordinate of the kpoint should be entered in bohrs. See Nexus
tutorial for more detils on how to generate supercells.

3) We use density fitting to speedup computation. 
.. code-block:: python
       mydf = df.FFTDF(supcell,kpts)
       mydf.auxbasis = 'weigend'
 
In this case we use FFTDF. However, Pyscf offers a few option with various Pros/Cons. 
Look at https://sunqm.github.io/pyscf/pbc/df.html?highlight=fftdf for more options.

4) Identical calculation but with DFT can be run. Instead of:
.. code-block:: python
      mf = scf.KRHF(supcell,kpts).density_fit()

One can use DFT with B3LYP functional as follow:

.. code-block:: python
      mf = dft.KRKS(supcell,kpts).density_fit()
      mf.xc="b3lyp"


In order to generate the HDF5 necessary to run QMCPACK we call the function "savetoqmcpack" 
located in "qmcpack/src/QMCTools/PyscfToQmcpack.py".  
This will generate an HDF5 file named "$title.h5" (in this case H2O_DFT_BFD.h5) containing all 
information necessary to run QMCPACK. 
For this call to work, It is important to have "qmcpack/src/QMCTools/" in your PYTHONPATH.

We next run the pyscf calculation using

.. code-block:: bash

    python diamondC_2x1x1.py > diamondC_2x1x1.out

which will yield a converged restricted Hartree Fock total energy of -10.60336776896038 Ha/cell 




The next step is to generate the necessary qmcpack input from this scf calculation. 

.. code-block:: bash

    mpirun -n 1 convert4qmc -pyscf S2-twist1.h5 -production 

This operation will generate 3 files: 
  1- S2-twist1.structure.xml (present in the directory)
	This file contains the system geometry, the number of atoms and the number of electrons.
 
  2-  S2-twsit1.wfj.xml (present in the directory but not used)
	This file contains the trial wavefunction. The basis set, MO coefficients and all non mutable 
        data are stored in the HDF5 file referenced in the trial wavefunction. Only Jastrow data and 
        important information is kept in the HDF5. This allows a lighter IO and more user friendly inputs.

  3- S2-twist1.qmc.in.xml (not present in the directory)
        This file contains what is considered a "standard production" QMC block, from the Jastrow Optimmization 
        blocks, to VMC and DMC blocks. 
        IMPORTANT NOTE: THIS BLOCKS ARE NOT TAILORED FOR THE PROBLEM, MACHINE OR ACCURACY YOU MAY WANT TO REACH
                        THEY ARE TO BE USED AS GUIDE LINES TO BE MODIFIED AS SEEN IN THE FOLLOWING SECTIONS.


In this example, convert4qmc takes 3 arguments;
   1- -pyscf: The code name generating the HDF5. Other options are -QP (quantum package) or -gamess. Note that 
      the option -orbitals is also available and reads natively hdf5 files generated by QP and Pyscf. 
   2- $title.h5: the name of the HDF5 file. 
   3- -production : This flag will force to generate a set of "GUESS" Optimization blocks and VMC and DMC blocks
      for production. Please Note that these blocks are mainly suggestions and should be adapted to the system,
      machine and desired accuracies.
       
You will need to add the ECP files in the XML for QMCPACK to use. These ECP files in the QMCPACK format are provided as C.qmcpp.xml 

In the QMC input file containing the QMC Block, the Hamiltonian will contain.
.. code-block:: xml
  <hamiltonian name="h0" type="generic" target="e">
    <pairpot name="ElecElec" type="coulomb" source="e" target="e" physical="true"/>
    <pairpot name="IonIon" type="coulomb" source="ion0" target="ion0"/>
    <pairpot name="PseudoPot" type="pseudo" source="ion0" wavefunction="psi0" format="xml">
      <pseudo elementType="C" href="../C.qmcpp.xml"/>
    </pairpot>
  </hamiltonian>
 

Running QMC:

For the purpose of this tutorial, the optimization step of the Jastrows will be skipped as they are identical to the molecular examples
or the Solids examples using PW/splines. 

However, we will focus on the comparison between the VMC calculations without Jastrows (comparable to Hartree Fock).

Step 1- VMC run 
In the VMC directory, you will find 2 files (VMC.xml and S2-twist1.wfnoj.xml): 
1) S2-twist1.wfnoj.xml: 
This is a trial wavefunction containing no Jastrow function. 
You will notice multiple things:
  a) the twist tag
.. code-block:: xml
   twist="0  0  0"

This indicated the supertwist coordinates. It helps QMCPACK compute the phase factor when the Periodic boundaries are applied to the wavefunction.
When evaluating the orbitals with a periodicity, we multiply the value and derivatives of the orbitals by exp(-i k.g), where k is the vector of the 
supertwist and g is the translation vector. You will notice that when using certain supertwists (0 0 0) or (1/2, 1/2, 1/2) the phase will be 1 or -1
leading to a real wavefunction. In the case of different phase, the wavefunction becomes complex and one needs to use the complex version of QMCPACK. 

   b) The PBCImages tag
.. code-block:: xml
   PBCimages="5  5  5"

This is the number of periodic imahes where we want to evaluate the orbitals. Note that ideally, the number of periodic images is automated or converged manually. 
This is an optimization in progress. For the moment, the number 5 5 5 is significantly higher than expected for such a system but it is the user's responsability
to make sure it is well converged. 

 
2) VMC.xml:
  
  A VMC block with No Jastrow optimization to compare directly with Hartree Fock.

The reference energy can be found in the ref_files/VMC.s000.scalar.dat.

.. code-block:: bash
     mpirun -n 1 $HOME/apps/qmcpack/qmcpack/build_complex/bin/qmcpack VMC.xml | tee VMC.out
     qmca -q ev *.scalar.dat 
                             LocalEnergy               Variance           ratio 
     VMC  series 0  -21.204825 +/- 0.011473   4.322113 +/- 0.121838   0.2038 

The Hartree Fock energy for the superCell is -21.20673553792076 (within error Bars). 

Note that the QMC calulation is run in the super cell (2 cells). while the Hartree Fock is run in a primitive cell with 2 kpoints. 
Therefore there is a factor 2 in the energy that needs to be acknowledged. 

Step 2- DMC run

In the DMC directory, you will find 2 files (DMC.xml and S2-twist1.wfj.xml): 

In this case the wavefunction file S2-twist1.wfj.xml contains a pre optimized 1, 2 and 3 body Jastrow parameters. 
The DMC.xml contails 


For production run, ne needs to adjust the number of blocks/targetwalkers to reach the desired accuracy. 
In this case and for the AWS, This will lead to the following results:

.. code-block:: bash
     mpirun -n 1 $HOME/apps/qmcpack/qmcpack/build_complex/bin/qmcpack DMC.xml | tee DMC.out
     qmca -q ev *.scalar.dat 

                            LocalEnergy               Variance           ratio 
     DMC  series 0  -21.672800 +/- 0.028277   1.330476 +/- 0.034129   0.0614 
     DMC  series 1  -21.912048 +/- 0.011781   1.299570 +/- 0.005588   0.0593 





