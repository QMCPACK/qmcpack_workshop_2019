Nexus Examples
==============

These examples illustrate basic usage of Nexus in the context of 
driving calculations of a single physical system at a time with a 
variety of codes and methods.  The examples are organized by the 
code from which QMCPACK obtains determinant information for the 
trial wavefunction: Quantum Espresso, PySCF, and Quantum Package.  

All of the examples are for the real space version of QMCPACK and 
cover wavefunction optimization, VMC and DMC.  The AFQMC functionality 
is newer and will be added to Nexus in the near future.

If you have not worked with Nexus before, consider working through 
the first couple of Quantum Espresso examples first as they are more 
detailed. A summary of the examples is given below.  Information about 
resources to learn more about Nexus can be found in the last section 
below.


Quantum Espresso + QMCPACK Examples
-----------------------------------
These are located in the ``quantum_espresso`` directory. Examples 
include:

1. Performing a single DFT calculation with Quantum Espresso for a diamond primitive cell.
2. Performing VMC with QMCPACK for a matrix-tiled diamond supercell, including SCF, NSCF, orbital conversion, Jastrow optimization, and VMC steps.
3. Performing twist-averaged (ensemble) VMC calculations with QMCPACK for the diamond primitive cell.
4. Performing DMC timestep extrapolation with QMCPACK for a matrix-tiled diamond supercell.


PySCF + QMCPACK Examples
------------------------
These are located in the ``pyscf`` directory. Examples 
include:

1. Performing a single restricted Hartree-Fock calculation with PySCF for a water molecule.
2. Performing a single RHF calculation in periodic BC's with PySCF: diamond primitive cell.
3. Performing VMC and DMC with QMCPACK for a water molecule, including RHF, orbital conversion, nuclear cusp correction, two- and three-body Jastrow optimization, and VMC/DMC.
4. Performing VMC and DMC with QMCPACK for a 2x1x1 tiled diamond supercell, including RHF, orbital conversion, two-body Jastrow optimization, and VMC/DMC. 


Quantum Package + QMCPACK Examples
----------------------------------
These are located in the ``quantum_package`` directory. Examples 
include:


1. Performing a single restricted Hartree-Fock calculation with Quantum Package for a water molecule.
2. Performing selected CI calculations with Quantum Package for a spin polarized oxygen dimer, including RHF, initial selected CI, natural orbital computation, and final selected CI.
3. Performing VMC and DMC with QMCPACK for a water molecule, including RHF, orbital conversion, nuclear cusp correction, two- and three-body Jastrow optimization, and VMC/DMC.
4. Performing VMC and DMC with QMCPACK based on multideterminant selected-CI wavefunctions for a spin polarized oxygen dimer, including RHF, initial selected CI, natural orbital computation, final selected CI, wavefunction conversion, nuclear cusp correction, two- and three-body Jastrow optimization, and VMC/DMC.


Nexus: Additional Resources
---------------------------

To learn more about Nexus, first see the Nexus manual

https://docs.qmcpack.org/nexus_user_guide.pdf

and the reference paper

https://doi.org/10.1016/j.cpc.2015.08.012

Please cite the reference paper if you use Nexus in your 
published work.

Use of Nexus is also covered in Labs 2, 4, and 5 in the QMCPACK manual,

https://docs.qmcpack.org/qmcpack_manual.pdf
 
which touch on QMC basics, condensed matter calculations, and excited state 
calculations, respectively.

For more information on particular topics, consider reviewing 
slides and demo materials from the Nexus user meetings that are 
held regularly.  The materials are hosted publicly on GitHub:

https://github.com/QMCPACK/nexus_training

Meeting topics with links can be found below:

1. Overview of Nexus including detailed usage of the settings function and command-line control:

https://github.com/QMCPACK/nexus_training/tree/master/monthly_meetings/01_181019_nexus_overview

2. Overview of working with Nexus across multiple machines.  Also includes information about bundling many jobs together in HPC environments:

https://github.com/QMCPACK/nexus_training/tree/master/monthly_meetings/02_181116_multiple_machines

3. Detailed information about working with and/or generating Quantum Espresso input with Nexus:

https://github.com/QMCPACK/nexus_training/tree/master/monthly_meetings/03_190118_pwscf_input

4. Detailed information about working with Quantum Package via Nexus.  This partially overlaps with the Quantum Package examples above, but visits other details as well:

https://github.com/QMCPACK/nexus_training/tree/master/monthly_meetings/05_190426_qp_qmcpack

