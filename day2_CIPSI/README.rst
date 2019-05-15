Example 1: H2O All Electron with a HF nodal surface
====================

In this example we will go through the basic steps necessary to
generate a Multideterminant DMC input from Quantum Package on a closed 
shell molecule H2O in all electrons and the cc-pcvtz basis set.

Quantum Package needs to be sourced at the beginning of session

.. code-block:: bash
    source $HOME/apps/qp2/quantum_package.rc

Quantum Package's Input file system is unique. It stores all the data in a directory system
managed by it's own manager called ezfio. 

To generate the necessary files, you need to create the input. This operation requires only
a standard XYZ file containing the geometry of the system.
In the directory, you will find an H2O.xyz file containing the Geometry of the system 
  
.. code-block:: bash 
   cat H2O.xyz
      3
      
      H             0.00000000       0.75720000      -0.46920000
      H             0.00000000      -0.75720000      -0.46920000
      O             0.00000000       0.00000000       0.11730000

Then you generate the ezfio containing all the required data to start a QP calculation

.. code-block:: bash 
      qp_create_ezfio H2O.xyz -b "O:cc-pcvtz |H:cc-pvtz"

In this example, we choose for Oxygen atom a Triple Zeta basis set allowing excitations from the core

To vizualize the Input in a more traditional way, you can evoke the editor:
  
.. code-block:: bash 
      qp_edit H2O.ezfio

This editor will not allow you to input garbage values (stupid proof). 

Please refer to the Quantum Package Manual for more details: https://quantumpackage.github.io/qp2/  

##############################################
Quantum Package canrun multiple methods (DFT, RSDFT, HF, CIS, CISD, MRCC etc...) 

All available methods can be found by typing:

.. code-block:: bash
      qp_run -h


1) Running HF (SCF)

We will start by generating initial orbitals (in this case Hartree Fock orbitals)

.. code-block:: bash
      qp_run scf H2O.ezfio | tee H2O-scf.out

The energy from Hartree Fock is: -76.05731727176526
(Reference files are located in $HOME/qmcpack_workshop_2019/day2_CIPSI/ref_files/SCF)


As mentionned in the talk, the objective is to have the best orbitals before starting a fullCI (sCI) run. 

In order to do so, we first try to build the best Natural orbitals we can. 
This can be done through multiple ways, either by running All single excitations  (CIS) then saving the natural 
orbitals, or run a smaller subset of Determinants and sving the natural Orbitals. We will chose the latter option


.. code-block:: bash
      
      echo "50000" > H2O.ezfio/determinants/n_det_max
      qp_run fci H2O.ezfio | tee H2O-fci0.out

This will force the system to exit when reaching 50k determinants. 

Results can be found in $HOME/qmcpack_workshop_2019/day2_CIPSI/ref_files/fci0 

Summary at N_det =        63603
-----------------------------------

# ============ =============================
                    State      1
# ============ =============================
# E            -76.37451832
# PT2            -0.01477441     0.00002951
#
# E+PT2         -76.38929273     0.00002951
# E+rPT2        -76.38927280     0.00002947
# ============ =============================



You can also plot the energy with the number of Determinants to see the convergence.

.. code-block:: bash
        qp_run print_e_conv H2O.ezfio

This will generate a file containing:

 # N_det    E_var        E_var + PT2
        5   -76.0573172718   -76.2361554219
       13   -76.0732585553   -76.3178084586
       13   -76.0854334660   -76.3941341302
       28   -76.1033489168   -76.3931962589
       60   -76.1220181998   -76.3910263968
      121   -76.1483140695   -76.3899292130
      246   -76.1747640049   -76.3877118512
      493   -76.2083861536   -76.3862180014
      990   -76.2435863367   -76.3863448967
     1984   -76.2819563909   -76.3868337904
     3973   -76.3165387200   -76.3874840990
     7948   -76.3443677787   -76.3882788690
    15897   -76.3628616042   -76.3889382581
    31795   -76.3708084406   -76.3890849717
    63603   -76.3745183175   -76.3892727982

You can plot this file using gnuplot using:
.. code-block:: bash

   gnuplot
   gnuplot> set logscale x
   gnuplot> plot "H2O.ezfio.1.conv" u 1:2 w l t 'E_{var}'
   gnuplot> replot "H2O.ezfio.1.conv" u 1:3 w l t 'E+PT_2'



Now the Wavefunction contains 63k determinants. We can save the natural orbitals.

.. code-block:: bash
   qp_run save_natorb H2O.ezfio

Now the ground state orbitals are better. 

we can run a better fci run with larger determinant set. A typical production run for DMC is ~1M determinnats.
For time reasons, we use 100k determinants and run fci and print the energy per determinants.. 

.. code-block:: bash 
   echo "100000" > H2O.ezfio/determinants/n_det_max
   qp_run fci H2O.ezfio | tee H2O-fci.out
   qp_run print_e_conv H2O.ezfio

The H2O.ezfio.1.conv generated file will have the following outputs:

 # N_det    E_var        E_var + PT2
        5   -76.0573172718   -76.2361554219
       13   -76.0732585553   -76.3178084586
       13   -76.0854334660   -76.3941341302
       28   -76.1033489168   -76.3931962589
       60   -76.1220181998   -76.3910264239
      121   -76.1483140695   -76.3899292298
      246   -76.1747640049   -76.3877117769
      493   -76.2083861536   -76.3862177172
      990   -76.2435863367   -76.3863448848
     1984   -76.2819563909   -76.3867931182
     3973   -76.3165387200   -76.3874855886
     7948   -76.3443677787   -76.3882785423
    15897   -76.3628616042   -76.3889476304
    31799   -76.3708089269   -76.3891108314
    63615   -76.3745188374   -76.3892910734
   127246   -76.3772529513   -76.3893769507
 
Note that the energy at similar number of determinants has significantly decreased since the selection was 
done on a better ground state orbitals. 


This operation (Saving the Natural Orbitals) can be repeated a few times until reaching a converged energy per determinant. 


#####################################################
Truncating the Wavefunction determinants for QMC.
As a reminder from the talk, large number of determinants have a "tail" containing excitations (determinants)
with significantly small coefficients. This high energy determinants are typical of the e-e cusp correction. 
DMC with Jastrow already corrects for the e-e cusp through the 2 body Jastrow. Therefore, DMC reachs convergence 
with the number of determinants faster than CIPSI.

The truncation algorithm is described in the talk (day2_CIPSI).   

In Short, the truncation is based on removing any determinant with a coefficient smaller than the specivied thershold 

We will select 4 different thresholds 1e-4, 1e-5 1e-6 and 1e-8

The procedure is done by:

- Setting the threshold:
Before doing so, Keep in mind that truncating the wavefunction will remove the determinants previously computed. 
It is preferable to create a separate directory, copy in it the ezfio directory and work in this new directory. 


.. code-block:: bash
   mkdir Truncate4
   cp -r H2O.ezfio Truncate4/
   echo "1.0e-04" > Truncate$i/H2O.ezfio/qmcpack/ci_threshold
   cd Truncate4
   qp_run truncate_wf_spin H2O.ezfio | tee H2O-Tr4.out

This will lead to the following results for a 1e-4 thershold:

 Number of determinants:        2602
 E(           1 ) =   -76.2250876174191

To get the PT2 energy corresponding to these determinants, we need to run a pt2 only run

.. code-block:: bash
   qp_run pt2 H2O.ezfio | tee H2O-Tr4.pt2.out
   
This will lead to the following result:


Summary at N_det =         2602
-----------------------------------

# ============ =============================
                    State      1
# ============ =============================
# E            -76.22508762
# PT2            -0.16030042     0.00006342
#
# E+PT2         -76.38538804     0.00006342
# E+rPT2        -76.38266028     0.00006234
# ============ =============================



All these results can be found in qmcpack_workshop_2019/day2_CIPSI/ref_files/Truncate4


##########################################################
Running QMCPACK


We will save the wavefunction for QMCPACK. 
.. code-block:: bash
   qp_run save_for_qmcpack H2O.ezfio > H2O-Tr4
 

The next step is to generate the necessary qmcpack input from this MSD calculation. 

.. code-block:: bash

    mpirun -n 1 convert4qmc -QP H2O-Tr4 -production -addCusp -hdf5

This operation will generate 3 files: 
  1- H2O-Tr4.structure.xml (present in the directory)
	This file contains the system geometry, the number of atoms and the number of electrons.
 
  2- H2O-Tr4.wfj.xml (present in the directory)
	This file contains the trial wavefunction. The basis set, MO coefficients and all non mutable 
        data are stored in the HDF5 file referenced in the trial wavefunction. Only Jastrow data and 
        important information is kept in the HDF5. This allows a lighter IO and more user friendly inputs.
        More importantly this file contains also the Multideterminant coefficients and excitations. 

  3- H2O-Tr4.qmc.in.xml (present in the directory)
        This file contains what is considered a "standard production" QMC block, from the Jastrow Optimmization 
        blocks, to VMC and DMC blocks. 
        IMPORTANT NOTE: THIS BLOCKS ARE NOT TAILORED FOR THE PROBLEM, MACHINE OR ACCURACY YOU MAY WANT TO REACH
                        THEY ARE TO BE USED AS GUIDE LINES TO BE MODIFIED AS SEEN IN THE FOLLOWING SECTIONS.


In this example, convert4qmc takes 5 arguments;
   1- -QP: The code name generating the HDF5. Other options are -pyscf (pyscf) or -gamess. Note that 
      the option -orbitals is also available and reads natively hdf5 files generated by QP and Pyscf. 
   2- $title: the name of the QP txt output file. 
   3- -production : This flag will force to generate a set of "GUESS" Optimization blocks and VMC and DMC blocks
      for production. Please Note that these blocks are mainly suggestions and should be adapted to the system,
      machine and desired accuracies.
   4- -addCusp:  Since we are running an all electron calculation, we need a scheme to forbid electrons to move 
       too close to the nuclei. Adding this tag will modify the orbitals and will add a cusp correction to the orbitals.
       in the Trial Wave function file the Cusp Correction scheme is triggered by the following lines:    
   5- -hdf5: This will dump all the data into an HDF5 files named $title.orbs.h5

    
.. code-block:: xml
    <determinantset type="MolecularOrbital" name="LCAOBSet" source="ion0" transform="yes" cuspCorrection="yes" href="../H2O-Tr4.orbs.h5">
The tag CuspCorrection=yes will call the CuspCorrection. 

The Cusp Correction will be done for the orbotals in spin up and orbitals in spin down. While this operation is relatively fast for 
small molecules, specially when only occupied orbitals are to be considered, it might be necessary store the correction parameters. 
If already stored, the parameters (updet.cuspInfo.xml and downdet.cuspInfo.xml) can be speicified as follow in the wfj.xml file:

.. code-block:: xml
      <sposet basisset="LCAOBSet" name="spo-up" size="71" cuspInfo="../CuspCorrection/spo-up.cuspInfo.xml">


.. code-block:: xml
   <multideterminant optimize="no" spo_up="spo-up" spo_dn="spo-dn">
        <detlist size="2602" type="DETS" nca="0" ncb="0" nea="5" neb="5" nstates="71" cutoff="1e-20" href="../H2O-Tr4.orbs.h5"/>
      </multideterminant>

This is the multideterminant tag in the WFJ specifying the number of determinant in the expansion, 
the cutoff to pick and if we desire to optimize the coefficients. 

Note that if you decide to optimize the coefficients, the IO does not handle yet the saving of the new 
optimized coefficients in HDF5. You might want to run with the tag -hdf5 in the convert4qmc step.


Running QMC:
Step 1- CuspCorrection AND a VMC block with No Jastrow to compare our result to HF (files in ref_files/CuspCorrection.
   
.. code-block:: bash 
      cd CuspCorrection
      mpirun -n 1 qmcpack Cusp.xml | tee Cusp.out

NOTE: Compare carefully the Cusp.xml and H2O-Tr4.wfj.xml files (provided in the directory) and the H2O-Tr4.qmc.in.xml and 
H2O-Tr4.wfj.xml  generated by convert4qmc. You will notice the lack of Jastrow functions (to capture only the Antysymmetric 
part of the trial wavefunction and a longer than necessary VMC block to compare to the HF Energy.   

in /qmcpack_workshop_2019/day2_CIPSI/ref_files/Truncate4/CuspCorrection
 
CIPSI energy:  -76.22508762 Ha.
.. code-block:: bash 
     qmca -q ev *.scalar.dat
                            LocalEnergy               Variance           ratio 
     H2O-Tr4  series 0  -76.227476 +/- 0.008925   18.168231 +/- 1.032945   0.2383 


You will notice that the CIPSI energy and the VMC energy are the same (within error bar). This is a good test to make sure that your TWF is not broken



 

Step 2- Jastrow Optimization:
In the Optimization directory, we modify slightly the Jastrow to have 20 parameters for the 2 body Jastrow with a cutoff of 10 Angstrom 
and 10 parameters and a cutoff of 5 Angstrom for the one body Jastrow. 

Since the starting parameters for the optimization are significantly bad (0 0 0 0 0 ...) we use 2 loops with different values, 
from "aggressive" to more restrictive.  Note the difference between the used number of samples (8000->80000)  and the value of 
minwalker (0.0001->0.1) between in the input file

.. code-block:: xml
  <loop max="4">
    <qmc method="linear" move="pbyp" checkpoint="-1">
      <parameter name="samples">80000</parameter>
      <parameter name="minwalkers">0.1</parameter>
    </qmc>
  </loop>

The Jastrow Optimization should always be made in 2 steps. First optimizing 1 and 2 body Jastrow (No 3 Bodies), Then in a second 
step adding 3 body Jastrows. This will avoid having to optimize too many parameters in one run and introducing too much instability

In the Optimization directory you will find an Opt.xml file containing the optimization blocks (whill start enumerating outputs 
from 0 to 14). The enumeration is controlled with the tag:

.. code-block:: xml
 
  <project id="H2O-Tr4" series="0"/>

The outcome of the optimization should generate 15 files named H2O_AE_HF.sXXX.scalar.dat where XXX=000..014
IMPORTANT: The optimized Jastrow Parameters will be in the H2O_AE_HF.sXXX.opt.xml files. These files can replace a wfj.xml Wavefunction
To select the est JAstrow Parameters they need to lead to the lowest VMC energy: 

.. code-block:: bash 
     mpirun -n 1 qmcpack Opt.xml | tee Opt.out
     qmca -q ev *.scalar.dat | sort -k4

                            LocalEnergy               Variance           ratio 
      H2O-Tr4  series 0  -76.025724 +/- 0.022344   4.768431 +/- 0.169258   0.0627 
      H2O-Tr4  series 1  -76.220140 +/- 0.012262   4.507318 +/- 0.037389   0.0591 
      H2O-Tr4  series 3  -76.359437 +/- 0.003894   3.242233 +/- 0.119802   0.0425 
      H2O-Tr4  series 5  -76.366238 +/- 0.003334   3.402459 +/- 0.096002   0.0446 
      H2O-Tr4  series 2  -76.369754 +/- 0.003566   2.926845 +/- 0.076496   0.0383 
      H2O-Tr4  series 12  -76.371904 +/- 0.002203   3.365235 +/- 0.070266   0.0441 
      H2O-Tr4  series 11  -76.372241 +/- 0.004755   3.386355 +/- 0.101990   0.0443 
      H2O-Tr4  series 8  -76.372820 +/- 0.002516   3.356288 +/- 0.057815   0.0439 
      H2O-Tr4  series 10  -76.374386 +/- 0.003533   3.373818 +/- 0.057947   0.0442 
      H2O-Tr4  series 4  -76.374930 +/- 0.002769   3.234819 +/- 0.041435   0.0424 
      H2O-Tr4  series 9  -76.375493 +/- 0.003108   3.399608 +/- 0.079824   0.0445 
      H2O-Tr4  series 6  -76.376614 +/- 0.002976   3.379360 +/- 0.056925   0.0442 
      H2O-Tr4  series 14  -76.377627 +/- 0.002318   3.270833 +/- 0.038892   0.0428 
      H2O-Tr4  series 13  -76.378476 +/- 0.002499   3.262175 +/- 0.035994   0.0427 
      H2O-Tr4  series 7  -76.379613 +/- 0.002970   3.314045 +/- 0.050037   0.0434 


 In the case, the energy in the series 07 was computed using the Jastrow from the previous round. 
Explanation: At the end of an optimization block N, we generate a series of Jastrow parameters. These will be used to evaluate a VMC energy at Loop N+1.
Therefore if the Energy of Series 7 are what we want to reproduce, we must pick the coefficient computed at series 6

.. code-block:: bash
    cp H2O-Tr4.s006.opt.xml H2O-Tr4.wfj.xml


At this point, one needs to uncomment the 3J in the wavefunction file and change the series number to 15 in the opt.xml file and resubmit again


.. code-block:: bash 
     mpirun -n 1 qmcpack Opt.xml | tee Opt.out
     qmca -q ev *.scalar.dat | sort -k4

                            LocalEnergy               Variance           ratio 
      H2O-Tr4  series 0  -76.025724 +/- 0.022344   4.768431 +/- 0.169258   0.0627 
      H2O-Tr4  series 1  -76.220140 +/- 0.012262   4.507318 +/- 0.037389   0.0591 
      H2O-Tr4  series 17  -76.351125 +/- 0.012637   5.464381 +/- 0.174177   0.0716 
      H2O-Tr4  series 3  -76.359437 +/- 0.003894   3.242233 +/- 0.119802   0.0425 
      H2O-Tr4  series 5  -76.366238 +/- 0.003334   3.402459 +/- 0.096002   0.0446 
      H2O-Tr4  series 2  -76.369754 +/- 0.003566   2.926845 +/- 0.076496   0.0383 
      H2O-Tr4  series 12  -76.371904 +/- 0.002203   3.365235 +/- 0.070266   0.0441 
      H2O-Tr4  series 11  -76.372241 +/- 0.004755   3.386355 +/- 0.101990   0.0443 
      H2O-Tr4  series 8  -76.372820 +/- 0.002516   3.356288 +/- 0.057815   0.0439 
      H2O-Tr4  series 10  -76.374386 +/- 0.003533   3.373818 +/- 0.057947   0.0442 
      H2O-Tr4  series 4  -76.374930 +/- 0.002769   3.234819 +/- 0.041435   0.0424 
      H2O-Tr4  series 9  -76.375493 +/- 0.003108   3.399608 +/- 0.079824   0.0445 
      H2O-Tr4  series 6  -76.376614 +/- 0.002976   3.379360 +/- 0.056925   0.0442 
      H2O-Tr4  series 14  -76.377627 +/- 0.002318   3.270833 +/- 0.038892   0.0428 
      H2O-Tr4  series 13  -76.378476 +/- 0.002499   3.262175 +/- 0.035994   0.0427 
      H2O-Tr4  series 7  -76.379613 +/- 0.002970   3.314045 +/- 0.050037   0.0434 
      H2O-Tr4  series 18  -76.383682 +/- 0.005625   2.366414 +/- 0.204617   0.0310 
      H2O-Tr4  series 25  -76.389879 +/- 0.002329   2.444350 +/- 0.150493   0.0320 
      H2O-Tr4  series 26  -76.390369 +/- 0.002631   2.372061 +/- 0.165947   0.0311 
      H2O-Tr4  series 21  -76.391006 +/- 0.003673   2.163881 +/- 0.074679   0.0283 
      H2O-Tr4  series 27  -76.394405 +/- 0.002461   2.236261 +/- 0.163502   0.0293 
      H2O-Tr4  series 22  -76.394863 +/- 0.003518   2.429305 +/- 0.241301   0.0318 
      H2O-Tr4  series 29  -76.395747 +/- 0.002400   2.251763 +/- 0.075277   0.0295 
      H2O-Tr4  series 19  -76.397214 +/- 0.002799   2.136584 +/- 0.104196   0.0280 
      H2O-Tr4  series 24  -76.397310 +/- 0.001727   2.249474 +/- 0.065663   0.0294 
      H2O-Tr4  series 20  -76.397525 +/- 0.002868   2.179612 +/- 0.054628   0.0285 
      H2O-Tr4  series 28  -76.397937 +/- 0.005413   2.299146 +/- 0.097450   0.0301 
      H2O-Tr4  series 23  -76.399658 +/- 0.003061   2.280167 +/- 0.073538   0.0298 
      H2O-Tr4  series 16  -76.468552 +/- 0.026476   4.994365 +/- 0.062222   0.0653 
      H2O-Tr4  series 15  -76.687862 +/- 0.032392   4.812652 +/- 0.237690   0.0628 
 

You will notice that the Variance improved significantly from not using a Jastrow to using a well converged Jastrow. 

While the Jastrow do not change the ndal surface for All electron calculations, They reduce significantly the variance, leading to a faster cnvergence at the DMC level
Note that the steps 15 and 16 have widely bad variance. They are to be discarded. Instead the series 23 seems great.
 

Step3- VMC DMC

The VMC directory contains the DMC.xml input file with a VMC block (to select better samples and reduce the DMC equilibration time)
and a DMC block. 

For production run, ne needs to adjust the number of blocks/targetwalkers to reach the desired accuracy. 
It is also necessary to copy the optimizedtrial wavefunction to the correct directory.
In this case and for the AWS, This will lead to the followin answers:

.. code-block:: bash
    cp Optimization/H2O-Tr4.s022.opt.xml DMC/H2O-Tr4.wfj.xml
    mpirun -n 1 qmcpack DMC.xml | tee DMC.out 
    qmca -q ev *.scalar.out

                            LocalEnergy               Variance           ratio 
    H2O-Tr4  series 0  -76.394474 +/- 0.002464   2.113535 +/- 0.056227   0.0277 
    H2O-Tr4  series 1  -76.423115 +/- 0.000877   2.256924 +/- 0.026630   0.0295 


Reproduce the eenrgies for Truncate5 Truncate6 and Truncate8.

                            LocalEnergy               Variance           ratio 
Truncate4/DMC/H2O-Tr4  series 1  -76.423088 +/- 0.000857   2.258768 +/- 0.026069   0.0296 
Truncate5/DMC/H2O-Tr5  series 1  -76.425353 +/- 0.001063   2.952116 +/- 0.026040   0.0386 
Truncate6/DMC/H2O-Tr6  series 1  -76.426460 +/- 0.000743   3.191128 +/- 0.018939   0.0418 
Truncate8/DMC/H2O-Tr8  series 1  -76.428732 +/- 0.001153   3.249729 +/- 0.132434   0.0425 



You can plot the DMC data with the amount of truncation in the X axis and extrapolate to 1e-20 coeff size.

Or Better, you can plot the DMC data in function of the PT2 energy. This will allow you to extrapolate to a 0 error in the PT2. 

#Nb_Det           #PT2                          #DMC
2602     -0.160300423166565         -76.423088 +/- 0.000857
18863    -6.866748295432973E-002    -76.425353 +/- 0.001063
44694    -2.732998375235876E-002    -76.426460 +/- 0.000743
98113    -1.302276339321704E-002    -76.428732 +/- 0.001153
2000000  -0.228036342295070E-002    -76.430150 +/- 0.000752

The last value added comes from a large run using 2M determinants 

The extrapolation leads to a 76.43182 +/- 0.001 Ha energy (Still far from exact value). 



