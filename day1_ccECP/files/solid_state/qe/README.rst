ccECP Example 3: Solid State example with Quantum Espresso
==========================================================

In this final example, we will illustrate the use of our ccECPs with quantum espresso.
To utilize our ccECPs within plane-wave codes like quantum espresso, we need a modified potential since plane wave codes do not use purely semi-local potentials like ours.
Instead, these utilize fully non-local potentials, known as Kleinmann-Bylander potentials. 
While this KB comes with many benefits, such as efficient evaluation in the plane-wave basis, it also can introduce a variety of issues.
Some of the issues are addressed in the *.rpt* file, which can be downloaded from pseudopotentiallibrary.org. 
This is generated from a modified version of OPIUM, which can generate KB transformations for a variety of semi-local potentials, and perform ghost state testing, transferability, and plane-wave cutoff estimation at the DFT level. 

.. code-block:: bash

  wget http://pseudopotentiallibrary.org/recipes/C/ccECP/C.upf
  wget http://pseudopotentiallibrary.org/recipes/C/ccECP/C.rpt

If we investigate the *.rpt* file, we can find the relevant information.

**Ghost States**

Ghost states  occur when the lowest energy states have the wrong number of nodes. 
Within QMC, the existence of ghost states can cause issues both with the covergence of the SCF, but also optimization of the Jastrow, large flucuations in VMC and DMC, instability of walker populations, etc (see `Drummond, Trail & Needs <https://journals.aps.org/prb/abstract/10.1103/PhysRevB.94.165170>`_)
Before the soon to be released updates to OPIUM, which can deal with gaussian style semi-local pseudopotentials like our ccECPs, BFD, Stuttgart, etc., these potentials needed to be constructed from ppconvert, which is provided with QMCPACK.
This tool does not provide any ghost state checking, transferability, etc.
Therefore, everything had to be thoroughly tested. 
For the *.upf* files uploaded for our ccECPs, we can simply check the *.rpt* file to ensure there is not ghost states at the DFT level. 

.. code-block:: bash

  ### PS report ########################################

      Orbital       Ghost
      -----------------------------------------------------------------
	  100 	    no
	  210 	    no


  ### NL/SL report #####################################


  NL:Orbital    Filling       Eigenvalues[Ry]          Norm       Ghost
  ------------------------------------------------------------------
	  100 	 2.000	      -1.8994061622	  0.5269147933	    no
	  210 	 1.000	      -1.2463147015	  0.5139289547	    no

	  ========== No ghosts in potential!!========== 

        E_tot =       -9.9027869501 Ry


**Transferability**

Since we take our semi-local potentials to be an accurate representation of the many-body Hamiltonian, we want the KB version of our potential to match as the semi-local potential for a variety of states, systems, etc.
A reasonable check is to see that energies are reproduced for a number of atomic states, which is also performed with OPIUM and provided in the *.rpt* file.

.. code-block:: bash

  ### TC report ########################################

  Comparison of total energies
  Config	 E_sl(Ry)	 E_nl(Ry)	 Delta(eV)
  0       -9.902787       -9.902787       -0.000000
  1      -10.700429      -10.700446        0.000233
  2      -10.071747      -10.071751        0.000049
  3       -9.442983       -9.442983        0.000000
  4       -9.902787       -9.902787       -0.000000
  5       -9.252319       -9.252325        0.000080
  6       -8.604609       -8.604609        0.000000
  7       -8.140843       -8.140878        0.000480
  8       -7.490481       -7.490560        0.001082
  9       -6.848954       -6.848954        0.000000
  10       -4.613496       -4.613692        0.002665
  11       -4.000547       -4.000547        0.000000
  MAD (eV): 0.000382367
  
Note that for a the majority of atomic states, the KB versions (E_nl) reproduce the total eergy of the semilocal potential (E_sl) to less that 1 mRy.
This suggests that this *.upf* file should be reasonably tranferable, and should work for a number of states/systems.

**Plane-wave cutoff**

An important part of a plane-wave calculation is the cutoff, which determines the quality of the basis. 
The larger the cutoff, the more accurate/complete the basis. 
The required cutoff for your system will be dependent on the required cutoff of each atom in your system, and should be chosen accordingly.
The cutoff information is provided in the *.rpt* file

.. code-block:: bash


	   ===   Ecut necessary for ~1    eV convergence error / electron === 
	   --------------------------------------------------------------- 
		 	   Ecut[Ry] 	 error [meV/e] 
	  100  		   25 	          981.442 
	  210  		   38 	          997.824 
	   ===   Ecut necessary for ~100 meV convergence error / electron === 
	   --------------------------------------------------------------- 
		   	 Ecut[Ry] 	 error [meV/e] 
	  100  		   45 	           96.722 
	  210  		   91 	           97.371 

	   ===   Ecut necessary for  ~10 meV convergence error / electron === 
	   --------------------------------------------------------------- 
		   	 Ecut[Ry] 	 error [meV/e] 
	  100  		   98 	            9.994 
	  210  		   159 	            9.948 

	   ===   Ecut necessary for   ~1 meV convergence error / electron === 
	   --------------------------------------------------------------- 
		 	   Ecut[Ry] 	 error [meV/e] 
	  100  		   162 	            0.993 
	  210  		   238 	            0.982 


If we want roughly 1meV/electron accuracy, this suggests we should choose a cutoff of 238 Ry, since we should take the largest from each state.
Additionally, if we have multiple species, we should chose the largest cutoff from each atom in order to gaurantee satisfactory convergence.
For example, if we were studying a system with H, C, and O, we can check our suggested cutoffs.
H suggests 251 Ry, C suggests 238 Ry, and O suggests 379 Ry, so we would use at least 379 Ry.
Due to the accuracy of our potentials, the are necessarily harder than most potentials used in plane-wave codes and require much higher cutoffs.

**Quantum Espresso**

We set the exact same diamond calculation as we did for PySCF, below in the *diamond.in* file.

.. code-block:: bash

	&CONTROL
   	calculation     = 'scf'
   	disk_io         = 'low'
   	outdir          = 'pwscf_output'
   	prefix          = 'pwscf'
   	pseudo_dir      = './'
   	restart_mode    = 'from_scratch'
   	tprnfor         = .false.
   	tstress         = .false.
   	verbosity       = 'high'
   	wf_collect      = .true.
	/

	&SYSTEM
   	celldm(1)       = 1.0
   	degauss         = 0.0001
   	ecutrho         = 952
   	ecutwfc         = 238
   	ibrav           = 0
   	input_dft       = 'pbe'
   	nat             = 2 
   	nosym           = .true.
   	ntyp            = 1
   	occupations     = 'smearing'
   	smearing        = 'fermi-dirac'
   	tot_charge      = 0
	/

	&ELECTRONS                                                 
   	conv_thr        = 1e-08
   	electron_maxstep = 1000
   	mixing_beta     = 0.7
	/  	 

	ATOMIC_SPECIES                                             
   	C  12.011 C.upf

	ATOMIC_POSITIONS alat
   	C        0.00000000       0.00000000       0.00000000
   	C        1.68658058       1.68658058       1.68658058

	K_POINTS automatic
   	1 1 1  0 0 0  

	CELL_PARAMETERS cubic
   	 3.37316115       3.37316115       0.00000000      
   	 0.00000000       3.37316115       3.37316115      
   	 3.37316115       0.00000000       3.37316115 
		 
The important information regarding the use of our ECP is in the ATOMIC_SPECIES section, where we simply provide the *.upf* file.
Additionally, the planewave cutoff is given in the ecutwfc, where I have provided 240, which is close to the suggested cutoff from the *.rpt* file. 

We can run this as 

.. code-block:: bash
	
	mpirun -np 8 pw.x < diamond.in > diamond.out
	grep total\ energy diamond.out | grep \! | awk '{print "Total Energy is " $5/2 " Ha"}'
	
This should print the converged energy of -10.2777 Ha. 
Comparing this to our diamond calculation with -10.2757 Ha, we find that they are in good agreement. 
We can test the planewave cutoff to see if the suggested cutoff is reasonable:

- 100 Ry: -10.2611 Ha
- 150 Ry: -10.2752 Ha
- 200 Ry: -10.2773 Ha
- 238 Ry: -10.2777 Ha
- 300 Ry: -10.2778 Ha

From the above experiment, it seems that we are well converged in the total energy by the suggested cutoff, and that our gaussian basis set using a VTZ basis is almost fully converged as well. 

**Final Comments**

Although our current table of ccECPs is limited with *.upf* files, they are being periodicially updated as more are tested. 
In the interim, particularly for transition metals, the potentials developed by `Krogel (2016) <https://journals.aps.org/prb/abstract/10.1103/PhysRevB.93.075143>`_ are reliable and accurate, and can be found at the pseudopotentiallibrary under the tag RRKJ_PRB_93_075143 and TM_PRB_93_075143. 
These will generally required cutoffs on the order of 300 Ry.

To perform QMCPACK calculations, you will need to only download the accompanying *.xml* file and run the approriate converter (convert4qmc for gaussian basis set codes and pw2qmcpack for quantum espresso) and proceed with the QMC workflow.
