This is a test system of 4 Hydrogens with orbital optimization mult-Slater Jastrow wave function
  
The atomic positions are in H4.ptcl.xml

The wave function is in H4.wfn.xml, there are 12 orbital parameters, 2 CI parameters, 30 Jastrow parameters to optimize

The QMCPACK input file is in H4_msd_orb_opt.xml

The expected output is in opt-ref/

to run it, just do
qmcpack H4_msd_orb_opt.xml output
