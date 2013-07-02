i = 1;
trmm_1C21_dir = 'C:\school\data\trmm-2010-day-60\1C21\';
trmm_2A21_dir = 'C:\school\data\trmm-2010-day-60\2A21\';

trmm_1B21_name = '';

cloudsat_file = 'C:\school\data\cloudsat-2010-day-60\hdf\2010060225029_20440_CS_2B-GEOPROF_GRANULE_P_R04_E03.hdf';

CPR_Height = hdfread(cloudsat_file, '/2B-GEOPROF/Geolocation Fields/Height', 'Index', {[1  1],[1  1],[37082    125]});
CPR_Latitude = hdfread(cloudsat_file, '/2B-GEOPROF/Geolocation Fields/Latitude', 'Fields', 'Latitude', 'FirstRecord',1 ,'NumRecords',37082);
CPR_Longitude = hdfread(cloudsat_file, '/2B-GEOPROF/Geolocation Fields/Longitude', 'Fields', 'Longitude', 'FirstRecord',1 ,'NumRecords',37082);
CPR_Time = hdfread(cloudsat_file, '/2B-GEOPROF/Geolocation Fields/Profile_time', 'Fields', 'Profile_time', 'FirstRecord',1 ,'NumRecords',37082);
CPR_Reflectivity = hdfread(cloudsat_file, '/2B-GEOPROF/Data Fields/Radar_Reflectivity', 'Index', {[1  1],[1  1],[37082    125]});

trmm_1C21_file = sprintf('%s%s', trmm_1C21_dir, regexprep(trmm_1B21_name, '1B21', '1C21'));
trmm_2A21_file = sprintf('%s%s', trmm_1C21_dir, regexprep(trmm_1B21_name, '1B21', '2A25'));

PR_Latitude = hdfread('C:\school\data\trmm-2010-day-60\1C21\1C21.20100301.70014.7.HDF', '/Swath/Latitude', 'Index', {[1  1],[1  1],[9246    49]});
PR_Longitude;
PR_Time;
PR_Reflectivity = hdfread(trmm_1C21_file, '/Swath/normalSample', 'Index', {[1  1  1],[1  1  1],[9246    49   140]});
PR_Corrected_Z =  hdfread(trmm_2A21_file, '/Swath/correctZFactor', 'Index', {[1  1  1],[1  1  1],[9246    49    80]});
PR_Rain_Rate = hdfread(trmm_2A21_file, '/Swath/rain', 'Index', {[1  1  1],[1  1  1],[9246    49    80]});