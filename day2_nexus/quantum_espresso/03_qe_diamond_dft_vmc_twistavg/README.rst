Nexus QE+QMCPACK Example 3: Diamond cubic cell (twist averaged VMC)
===================================================================

In this example, we expand on the previous example to include twist 
averaging.  The NSCF calculation is updated to generate orbitals for 
a 2x2x2 supercell twist grid.  Using a Jastrow factor optimized only 
at the Gamma point, VMC calculations are performed for each twist.

The Nexus script used for this example is ``diamond_lda_vmc_twistavg.py``.
Important differences between this script and the Gamma-point only 
one from the prior example are shown below:

.. parsed-literal::

    system = generate_physical_system(
        ...
        **kgrid  = (2,2,2), \# 2x2x2 supercell twist grid
        kshift = (0,0,0),**
        ...
        )
    
    scf = generate_pwscf(
        ...
        )
    
    nscf = generate_pwscf(
        **path = 'diamond/nscf_twist', \# new nscf run**
        ...
        )
    
    conv = generate_pw2qmcpack(
        **path = 'diamond/nscf_twist', \# new orb conversion**
        ...
        )
    
    opt = generate_qmcpack(
        ...
        )
    
    qmc = generate_qmcpack(
        **path = 'diamond/vmc_twist', \# new vmc run
        \# run with 8 mpi tasks, one per twist
        job  = job(cores=16,threads=2,app='qmcpack'),**
        ...
        )

The NSCF run will be performed in a new directory.  When NSCF is 
performed in a separate directory, as in this case, Nexus copies the 
SCF output into the new NSCF directory via rsync.  In this way, the 
converged charge density from a single SCF run can be re-used to make 
orbitals for a number of different QMC supercells.

Another important difference is that the VMC job has been modified 
so that one mpi task will be assigned to each of the eight twists in 
the batched VMC run.

Before running this example, let's copy in the completed runs from 
the prior example:

.. code-block:: bash

    >rsync -av ../02_qe_diamond_dft_vmc/runs ./

Now confirm that the prior runs are complete from Nexus' point of view:

.. code-block:: bash

    >./diamond_lda_vmc_twistavg.py --status_only
  
    ...
  
    cascade status 
      setup, sent_files, submitted, finished, got_output, analyzed, failed 
      111111  0  17009     scf     ./runs/diamond/scf  
      000000  0  ------    nscf    ./runs/diamond/nscf_twist  
      000000  0  ------    conv    ./runs/diamond/nscf_twist  
      111111  0  17362     opt     ./runs/diamond/optJ2  
      000000  0  ------    vmc     ./runs/diamond/vmc_twist  
      setup, sent_files, submitted, finished, got_output, analyzed, failed 

