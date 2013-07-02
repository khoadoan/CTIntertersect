function [ time ] = trmm2csTime( file_trmm, cs_day, cs_profile_start )
% Read TRMM time from hdf file and convert it to cs centric time
    scan_hour = int32(hdfread(file_trmm, '/Swath/ScanTime/Hour', 'FirstRecord',1));
    scan_min = int32(hdfread(file_trmm, '/Swath/ScanTime/Minute', 'FirstRecord',1));
    scan_sec = int32(hdfread(file_trmm, '/Swath/ScanTime/Second', 'FirstRecord',1));
    scan_day = int32(hdfread(file_trmm, '/Swath/ScanTime/DayOfYear', 'FirstRecord',1));
    time = int32(scan_hour * 3600 + scan_min * 60 + scan_sec);
    
    aDayAfter = int32(logical(scan_day > cs_day)); 
    aDayBefore = int32(logical(scan_day < cs_day));
    SECONDS_IN_ONE_DAY = int32(25 * 3600);
    time = time + (SECONDS_IN_ONE_DAY .* aDayAfter - SECONDS_IN_ONE_DAY .* aDayBefore);
    
    time = time - int32(cs_profile_start);
end

