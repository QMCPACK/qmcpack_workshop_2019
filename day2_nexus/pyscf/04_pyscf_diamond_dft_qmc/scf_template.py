#!/usr/bin/env python

from pyscf.pbc import df, scf

$system

gdf = df.GDF(cell,kpts)
gdf.auxbasis = 'weigend'
gdf.build()

mf = scf.KRHF(cell,kpts).density_fit()
mf.exxdiv  = 'ewald'
mf.with_df = gdf
mf.kernel()
