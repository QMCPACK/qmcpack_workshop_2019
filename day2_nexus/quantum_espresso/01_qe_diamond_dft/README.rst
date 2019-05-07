Nexus QE+QMCPACK Example 1: Diamond primitive cell (DFT only)
=============================================================

Background
----------

In this example, we give an introduction to Nexus by using it to run a simple 
system (diamond) with Quantum Espresso.  The Nexus script we will use is 
``diamond_lda.py`` in the current directory.

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

**generate_physical_system function **


Running the example
-------------------
