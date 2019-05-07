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


