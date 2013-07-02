function [latitude, longitude, time] = read_trmm( dir_trmm, name_trmm, dayOfYear, currentYear )
    % DESCRIPTION: Read data from TRMM Orbit File
    % param dir_trmm: path to TRMM Orbit Directory
    % param name_trmm: name of TRMM Orbit File
    % param dayOfYear: day of Year
    % param currentYear: year
    % return latitude: latitude matrix of readings x scans
    % return longitude: longitude matrix of readings x scans
    % return time: time vector of readings
    
    file_trmm = sprintf('%s%s', dir_trmm, name_trmm);
    latitude = hdfread(file_trmm, '/Swath/Latitude');
    longitude = hdfread(file_trmm, '/Swath/Longitude');
    scan_hour = hdfread(file_trmm, '/Swath/ScanTime/Hour', 'FirstRecord',1);
    scan_min = hdfread(file_trmm, '/Swath/ScanTime/Minute', 'FirstRecord',1);
    scan_sec = hdfread(file_trmm, '/Swath/ScanTime/Second', 'FirstRecord',1);
    scan_day = hdfread(file_trmm, '/Swath/ScanTime/DayOfYear', 'FirstRecord',1);
   
    time = (double(scan_hour) + double(scan_min)/60 + double(scan_sec)/3600)';
    aDayAfter = logical(scan_day > dayOfYear);
    aDayBefore = logical(scan_day < dayOfYear);
    time = time + 24 .* aDayAfter' - 24 .* aDayBefore';
    
    
end

