ccECP Example 1: Quantum Chemistry with PySCF
=============================================================

In this example, we illustrate how to utilize our ccECPs in quantum chemistry. 

Basis sets and ECPs can be found at `pseudopotentiallibrary.org <http://pseudopotentiallibrary.org>`_

QMCPACK can interface currently to a variety of quantum chemistry software, including GAMESS, Quantum Package, and PySCF. 
To utilize each code, simply download the appropriate ECP and basis set corresponding to each code. 

**GAMESS** will use basis sets/ECPs with the *.gamess* extension

**Quantum Package** will use basis sets/ECPs with the *.gamess* extension

**PySCF** will use basis sets/ECPs with the *.nwchem* extension

**QMCPACK** uses the *.xml* files

We can simply download the basis sets/ECPs for the atoms we are interested in. 
For example, for a GAMESS calculation using Oxygen and Hydrogen, we can simply execute. 

.. code-block:: bash

  wget http://pseudopotentiallibrary.org/recipes/H/ccECP/H.aug-cc-pVTZ.gamess
  wget http://pseudopotentiallibrary.org/recipes/H/ccECP/H.ccECP.gamess
  wget http://pseudopotentiallibrary.org/recipes/O/ccECP/O.cc-pVTZ.gamess
  wget http://pseudopotentiallibrary.org/recipes/O/ccECP/O.ccECP.gamess
  
A successful download will looks as follows for each download

.. code-block:: bash

  URL transformed to HTTPS due to an HSTS policy
  --2019-05-07 15:25:38--  https://pseudopotentiallibrary.org/recipes/O/ccECP/O.cc-pVTZ.gamess
  Resolving pseudopotentiallibrary.org (pseudopotentiallibrary.org)... 128.219.165.148
  Connecting to pseudopotentiallibrary.org (pseudopotentiallibrary.org)|128.219.165.148|:443... connected.
  HTTP request sent, awaiting response... 200 OK
  Length: 711
  Saving to: ‘O.cc-pVTZ.gamess’

  O.cc-pVTZ.gamess    100%[===================>]     711  --.-KB/s    in 0s      

  2019-05-07 15:25:38 (9.49 MB/s) - ‘O.cc-pVTZ.gamess’ saved [711/711]  


If there are errors, check the url and the filenames by navigating to the website.


PySCF example
-------------

We test PySCF on the Carbon atom with a cc-pVTZ basis.
With PySCF, we can use python functionality to download our ECPs directly. 

.. code-block:: python

  from urllib import urlretrieve

  #Obtain basis and ECP files from pseudopotentiallibrary.org
  atom = "C"
  pptype = "ccECP"
  bastype= "cc-pVTZ"
  pplib = "http://pseudopotentiallibrary.org/recipes"
  basfile="{0}.{1}.nwchem".format(atom,bastype)
  ecpfile="{0}.{1}.nwchem".format(atom,pptype)
  xmlfile="{0}.{1}.xml".format(atom,pptype) #grab qmcpack xml file for later
  urlretrieve("{0}/{1}/{2}/{3}".format(pplib,atom,pptype,basfile),
        filename=basfile)
  urlretrieve("{0}/{1}/{2}/{3}".format(pplib,atom,pptype,ecpfile),
        filename=ecpfile)
  urlretrieve("{0}/{1}/{2}/{3}".format(pplib,atom,pptype,xmlfile),
        filename=xmlfile)

Excecuting this, we should find that the files have been sucessfully downloaded into your current directory.

To use within PySCF, we now need to create the PySCF molecule object and read our downloaded basis and ecp.

.. code-block:: python
  
  import os
  from pyscf import gto
  
  cwd = os.getcwd()
  mol = gto.Mole()
  mol.atom = "{0} 0.0 0.0 0.0".format(atom)
  with open(os.path.join(cwd,basfile)) as f:
      bas = f.read()
  mol.basis = {atom: gto.basis.parse(bas)} 
  with open(os.path.join(cwd,ecpfile)) as f:
      ecp = f.read()
  mol.ecp = {atom: gto.basis.parse_ecp(ecp)}
  mol.spin = 2
  mol.charge = 0
  mol.build()
  
The above code initializes a Mole object, and opens the downloaded files defined in the previous lines.

Once the object is built, we can calculate the system with any quantum chemistry method, for example Hartree-Fock or DFT

.. code-block:: python

  from pyscf import scf,dft
  from PyscfToQmcpack import savetoqmcpack

  #run HF and PBE
  hf = scf.ROHF(mol)
  hf.kernel()
  pbe = dft.ROKS(mol)
  pbe.xc = 'pbe'
  pbe.kernel()

  savetoqmcpack(mol,hf,title='{}.hf'.format(atom))
  savetoqmcpack(mol,pbe,title='{}.pbe'.format(atom))

The above code is provided in Catom.py, which after exected should yield

.. code-block:: bash
  
  python Catom.py
  converged SCF energy = -5.31429524851345
  converged SCF energy = -5.40772137702074


