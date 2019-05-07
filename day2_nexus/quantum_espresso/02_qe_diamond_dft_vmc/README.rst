Nexus QE+QMCPACK Example 2: Diamond cubic cell (DFT+VMC)
========================================================

In this example, we expand on the simple SCF run of the diamond primitive 
cell (2 atoms) to include the steps necessary to perform VMC in a tiled 
cubic supercell (8 atoms).

The calculation steps performed in this example are:

1. SCF run with QE to obtain the charge density.
2. NSCF run with QE to obtain select orbitals to form the 8 atom supercell.
3. Orbital conversion step with pw2qmcpack to convert the NSCF orbitals into
the HDF5 format that QMCPACK reads.
4. Jastrow optimization with QMCPACK for the 8 atom supercell via the linear method.
5. VMC run with QMCPACK for the 8 atom supercell.

Apart from these steps, a main difference from the prior example is the 
tiling of the cell.  The tiling matrix from the fcc primitive cell to the 
simple cubic supercell is:

::

   1 -1  1
   1  1 -1
  -1  1  1

The supercell k-point (twist angle) we will use is the Gamma point. Nexus 
maintains a simultaneous representation of the folded primitive cell and its 
tiled supercell counterpart.  Eight k-points in the primitive cell BZ are 
equivalent to the supercell Gamma point.  The primitive cell, and its set of 
8 k-points, is used automatically in the NSCF calculation, while the supercell 
(with its single k-point/twist) is automatically used in the QMC calculations. 
The use of twist averaged boundary conditions will is covered in the next 
example.

The Nexus script used in this example, ``diamond_lda_vmc.py``, is shown below. 
Important differences from the prior example are bolded.

.. parsed-literal:: 

    #! /usr/bin/env python
    
    from nexus import settings,job,run_project
    from nexus import generate_physical_system
    from nexus import generate_pwscf
    from nexus import **generate_pw2qmcpack**  **\# used for pw2qmcpack** 
    from nexus import **generate_qmcpack**     **\# used for qmcpack**
    
    settings(
        pseudo_dir = '../../pseudopotentials',
        results    = '',
        sleep      = 3,
        machine    = 'ws16',
        )
    
    system = generate_physical_system(
        units    = 'A',
        axes     = '''1.785   1.785   0.000
                      0.000   1.785   1.785
                      1.785   0.000   1.785''',
        elem_pos = '''
                   C  0.0000  0.0000  0.0000
                   C  0.8925  0.8925  0.8925
                   ''',
        **tiling   = [[ 1, -1,  1],       \# tiling matrix
                    [ 1,  1, -1],
                    [-1,  1,  1]],
        kgrid    = (1,1,1),             \# supercell k-point grid
        kshift   = (0,0,0),**
        C        = 4,
        )
    
    **\# SCF run with QE to get charge density**
    scf = generate_pwscf(
        identifier   = 'scf',
        path         = 'diamond/scf',
        job          = job(cores=16,app='pw.x'),
        input_type   = 'generic',
        calculation  = 'scf',
        input_dft    = 'lda', 
        ecutwfc      = 200,   
        conv_thr     = 1e-8, 
        system       = system,
        pseudos      = ['C.BFD.upf'],
        kgrid        = (4,4,4),
        kshift       = (0,0,0),
        )
    
    **\# NSCF run with QE to get orbitals**
    nscf = generate_pwscf(
        identifier   = 'nscf',
        **path         = 'diamond/nscf',  \# nscf directory**
        job          = job(cores=16,app='pw.x'),
        input_type   = 'generic',
        **calculation  = 'nscf',          \# nscf calculation**
        input_dft    = 'lda', 
        ecutwfc      = 200,   
        conv_thr     = 1e-8, 
        system       = system,
        pseudos      = ['C.BFD.upf'],
        **nosym        = True,            \# no symmetry for k-points
        dependencies = (scf,'charge_density'), \# depends on scf**
        )
    
    **\# Orbital conversion with pw2qmcpack**
    conv = generate_pw2qmcpack(
        identifier   = 'conv',
        **path         = 'diamond/nscf',  \# run in nscf directory**
        job          = job(cores=16,app='pw2qmcpack.x'),
        write_psir   = False,
        **dependencies = (nscf,'orbitals'), \# depends on nscf**
        )
    
    **\# Jastrow optimization with QMCPACK**
    opt = generate_qmcpack(
        **block        = True,            \# don't run for now**
        identifier   = 'opt',
        path         = 'diamond/optJ2',
        job          = job(cores=16,threads=4,app='qmcpack'),
        input_type   = 'basic',
        system       = system,
        pseudos      = ['C.BFD.xml'],
        **J2           = True,            \# use two-body B-spline Jastrow
        qmc          = 'opt',           \# optimization run, variance opt
        cycles       = 6,               \# loop max=6
        samples      = 51200,           \# VMC samples used in each cycle
        dependencies = (conv,'orbitals'), \# depends on conversion**
        )
    
    **\# VMC with QMCPACK**
    qmc = generate_qmcpack(
        **block        = True,            \# don't run for now**
        identifier   = 'vmc',
        path         = 'diamond/vmc',
        job          = job(cores=16,threads=4,app='qmcpack'),
        input_type   = 'basic',
        system       = system,
        pseudos      = ['C.BFD.xml'],
        J2           = True,
        **qmc          = 'vmc',           \# vmc run, default inputs
        dependencies = [(conv,'orbitals'), \# depends on conversion
                        (opt,'jastrow')],  \# and on optimization**
        )
    
    run_project()


