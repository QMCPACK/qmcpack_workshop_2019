Nexus QE+QMCPACK Example 1: Diamond primitive cell (DFT only)
=============================================================

In this example, we give an introduction to Nexus by using it to run a simple 
system (diamond) with Quantum Espresso.  The Nexus script we will use is 
``diamond_lda.py`` in the current directory.

If you have not used Nexus before, we recommend you briefly read the 
*Background* section below.  Otherwise, feel free to proceed directly 
to *Running the Example*.


Background
----------

Each Nexus script has five main sections:

1. Module imports from Nexus (and/or other Python modules).
2. Setting variables to provide information and control Nexus' behavior.
3. Specifying the physical system (diamond in this case).
4. Specifying information for all simulation workflows (a single SCF 
calculation with QE here).
5. Execution of the simulation workflows.

These five sections are illustrated below using the ``diamond_lda.py`` as an 
example:


.. code-block:: python

    # Nexus module imports
    from nexus import settings,job,run_project
    from nexus import generate_physical_system
    from nexus import generate_pwscf
    
    # Setting Nexus variables 
    settings(
        ...
        )
    
    # Physical system information
    system = generate_physical_system(
        ...
        )
    
    # Simulation workflow information
    scf = generate_pwscf(
        ...
        )
    
    # Execute the workflows
    run_project()

Before running the example, we will give a little more information about the 
Nexus functions involved in sections 2-5. 

**settings function**

Provide basic information, such as the location of pseudopotential files 
and details of the local machine (workstation or named supercomputer like 
Summit).  Also provide basic information to control Nexus, such as the 
number of seconds between polling checks on simulation run status.

.. code-block:: python

    settings(
        pseudo_dir = '../../pseudopotentials', # directory with pseudo files
        results    = '',     # do not copy sim results into separate directory 
        sleep      = 3,      # poll simulation status every 3 seconds
        machine    = 'ws16', # machine is a 16 core workstation
        )

**generate_physical_system function**

Create an object containing details of the physical system, such as the atomic 
species, and atomic positions. If applicable, also provide effective charges of 
pseudo-atoms, cell axes, tiling matrix, and cell k-point grid.  The description 
of the physical system is made once and is shared between simulations in a 
workflow.  In addition to providing the atomic and cell information explicitly, 
this information can also be loaded directly from an appropriate ``xyz``, 
``xsf``, ``POSCAR``, or ``cif`` file (use ``structure=``*filepath*``,``).

.. code-block:: python

    # physical system object is assigned to a local variable named "system"
    system = generate_physical_system(
        # distances are in Angstrom units
        units    = 'A',
        # cell axes (can also provide as 3x3 list or array)
        axes     = '''1.785   1.785   0.000
                      0.000   1.785   1.785
                      1.785   0.000   1.785''',
        # atomic species and positions
        #   can also be provided separately (elem=list/array, pos=list/array)
        elem_pos = '''
                   C  0.0000  0.0000  0.0000
                   C  0.8925  0.8925  0.8925
                   ''',
        C        = 4,
        )

**generate_pwscf function**

Create a simulation object containing details about the simulation run 
directory, input/output file prefix, job submission information, and other 
simulation-specific keywords to generate the input file.

.. code-block:: python

    scf = generate_pwscf(
        identifier   = 'scf',         # prefix in/out files with "scf"
        path         = 'diamond/scf', # run directory location
        job          = ...            # job details, see "job function" below
        input_type   = 'generic',     # use standard inputs below
        # all PW inputs are allowed
        calculation  = 'scf',         # run an scf calculation
        input_dft    = 'lda',         # use lda functional
        ecutwfc      = 200,           # 200 Ry orbital plane-wave cutoff
        conv_thr     = 1e-8,          # convergence threshold of 1e-8 Ry
        system       = system,        # atom/cell information
        pseudos      = ['C.BFD.upf'], # pseudopotential files
        kgrid        = (4,4,4),       # 4x4x4 Monkhorst-Pack grid
        kshift       = (0,0,0),       # centered at Gamma
        )

**job function**

Create an object containing job submission information.  On a workstation this 
is primarly the number of cores and threads (mpi tasks will be set to 
#cores/#threads).  On a supercomputer, this also typically includes node count, 
wall time, and environment variable information.  On these machines job 
submission files are automatically created and executed.

.. code-block:: python

    job(cores=16,  # run on all 16 cores (16 mpi tasks)
        app='pw.x' # path to PW executable (defaults to pw.x)
        ),

**run_project function**

Execute all simulation runs.  Up to this point, the workflow information has 
been specified (e.g. via ``generate_pwscf``) but no simulation runs have been 
performed.  When this function is executed, all simulation dependencies are 
noted and simulations are executed in the order needed to satisfy all 
dependencies.  Multiple independent simulations will execute simultaneously 
(always true on a supercomputer/cluster, true on a workstation if there are 
sufficient free resources).  When executing the simulation runs, Nexus enters 
a polling loop to monitor simulation progress.  When this function completes, 
all simulation runs will also be complete.

.. code-block:: python

    # run the simulation workflows specified earlier
    run_project()


Running the Example
-------------------

First run the Nexus script with the ``status_only`` flag set.  This will show 
the queue of jobs that Nexus is managing, including their current status.

.. code-block:: bash

>./diamond_lda.py --status_only

  ...
  
  cascade status 
    setup, sent_files, submitted, finished, got_output, analyzed, failed 
    000000  0  ------    scf     ./runs/diamond/scf  
    setup, sent_files, submitted, finished, got_output, analyzed, failed 

The QE SCF run will be performed in ``./runs/diamond/scf`` and the input and 
output files will be prefixed with ``scf`` (scf.in and scf.out).  The status
flags, represented as ``0`` or ``1`` are described below.

**0**\ 00000  0  ------  setup

0\ **0**\ 0000  0  ------  sent_files

00\ **0**\ 000  0  ------  submitted

000\ **0**\ 00  0  ------  finished

0000\ **0**\ 0  0  ------  got_output

00000\ **0**  0  ------  analyzed

000000  **0**  ------  failed

000000  0  **------**  job_id

