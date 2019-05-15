This is an example of using BLM algorithm. The test system is carbon dimer with multi-slater Jastrow wave function. 

The wave function is in sample.Gaussian-G2.xml. spo-up.cuspInfo.xml and spo-dn.cuspInfo.xml contains cusp corrections to the orbitals. 

The qmcpack input file is qmcpack.xml, in which the following block turns on BLM and set its attributes:

       parameter name="block_lm" yes parameter

       parameter name="nblocks" 2 parameter

       parameter name="nolds"  parameter

       parameter name="nkept"  parameter

Normally for such a small system, you should use standard LM, therefore this is just a fast example for you to play around with BLM. 

To run it, use qmcpack qmcpack.xml > output

After the run is finished, you can grab the energy for each iteration by:

grep -B20 "Solving the linear method" output | grep "le_mean" > eng_iter.txt
