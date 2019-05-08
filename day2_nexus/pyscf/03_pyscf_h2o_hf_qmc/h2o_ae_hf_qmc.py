#! /usr/bin/env python

from nexus import settings,job,run_project,obj
from nexus import generate_physical_system
from nexus import generate_pyscf
from nexus import generate_convert4qmc
from nexus import generate_cusp_correction
from nexus import generate_qmcpack

settings(
    results    = '',
    sleep      = 3,
    machine    = 'ws16',
    )

system = generate_physical_system(
    structure = 'H2O.xyz',
    )

# perform Hartree-Fock
scf = generate_pyscf(
    identifier = 'scf',               # log output goes to scf.out
    path       = 'H2O/hf',            # directory to run in
    job        = job(serial=True),    # pyscf must run serially         
    template   = './scf_template.py', # pyscf template file
    system     = system,
    mole       = obj(                 # used to make Mole() inputs
        verbose  = 5,
        basis    = 'ccpvtz',
        symmetry = True,
        ),
    save_qmc   = True,                # save wfn data for qmcpack
    )

# convert orbitals to QMCPACK format
c4q = generate_convert4qmc(
    identifier   = 'c4q',
    path         = 'H2O/hf',
    job          = job(cores=1),
    no_jastrow   = True,
    hdf5         = True,          # use hdf5 format
    dependencies = (scf,'orbitals'),
    )

# calculate cusp correction
cc = generate_cusp_correction(
    identifier   = 'cusp',
    path         = 'H2O/cuspcorr',
    job          = job(cores=16,threads=16),
    system       = system,
    dependencies = (c4q,'orbitals'),
    )

# collect dependencies relating to orbitals
orbdeps = [(c4q,'particles'), # pyscf changes particle positions
           (c4q,'orbitals' ),
           (cc ,'cuspcorr' )]

# optimize 2-body Jastrow
optJ2 = generate_qmcpack(
    block             = True,
    identifier        = 'opt',
    path              = 'H2O/optJ2',
    job               = job(cores=16),
    system            = system,
    J2                = True,
    J1_rcut           = 4.0,
    J2_rcut           = 7.0,
    qmc               = 'opt',          # use opt defaults
    cycles            = 6,
    alloweddifference = 1e-3,
    dependencies      = orbdeps,
    )

# optimize 3-body Jastrow
optJ3 = generate_qmcpack(
    block             = True,
    identifier        = 'opt',
    path              = 'H2O/optJ3',
    job               = job(cores=16),
    system            = system,
    J3                = True,
    qmc               = 'opt',
    cycles            = 6,
    alloweddifference = 1e-3,
    dependencies      = orbdeps+[(optJ2,'jastrow')],
    )

# run VMC with QMCPACK
qmc = generate_qmcpack(
    block        = True,
    identifier   = 'vmc',
    path         = 'H2O/vmc',
    job          = job(cores=16),
    system       = system,
    jastrows     = [],
    qmc          = 'vmc',    # use vmc defaults
    blocks       = 800,
    steps        = 100,
    dependencies = orbdeps+[(optJ3,'jastrow')],
    )

# run DMC with QMCPACK
qmc = generate_qmcpack(
    block        = True,
    identifier   = 'dmc',
    path         = 'H2O/dmc',
    job          = job(cores=16),
    system       = system,
    jastrows     = [],
    qmc          = 'dmc',    # use dmc defaults
    eq_dmc       = True,     # add equilibration run
    dependencies = orbdeps+[(optJ3,'jastrow')],
    )

run_project()
