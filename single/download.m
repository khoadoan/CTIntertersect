mw = ftp('ftp://disc2.nascom.nasa.gov');
cd(mw, '/ftp/data/s4pa/TRMM_L1/TRMM_1C21/2010/091/');
mget(mw, '1C21.20100402.70512.7.HDF.Z');