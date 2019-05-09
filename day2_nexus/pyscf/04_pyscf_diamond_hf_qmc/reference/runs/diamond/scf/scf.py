#!/usr/bin/env python

from pyscf.pbc import df, scf


### generated system text ###
from numpy import array
from pyscf.pbc import gto as gto_loc
cell = gto_loc.Cell()
cell.a             = '''
                     3.37316115   3.37316115   0.00000000
                     0.00000000   3.37316115   3.37316115
                     3.37316115   0.00000000   3.37316115
                     '''
cell.basis         = 'bfd-vdz'
cell.dimension     = 3
cell.ecp           = 'bfd'
cell.unit          = 'B'
cell.atom          = '''
                     C    0.00000000   0.00000000   0.00000000
                     C    1.68658057   1.68658057   1.68658057
                     '''
cell.drop_exponent = 0.1
cell.verbose       = 5
cell.charge        = 0
cell.spin          = 0
cell.build()
kpts = array([
    [0.0, 0.0, 0.0],
    [0.4656748546088228, 0.4656748546088228, -0.4656748546088228]])
### end generated system text ###



gdf = df.FFTDF(cell,kpts)
gdf.auxbasis = 'weigend'

mf = scf.KRHF(cell,kpts).density_fit()
mf.exxdiv  = 'ewald'
mf.with_df = gdf
mf.kernel()

### generated conversion text ###
from PyscfToQmcpack import savetoqmcpack
savetoqmcpack(cell,mf,'scf',kpts)
### end generated conversion text ###

