function [time] = read_tmi_time( dir_tmi, name_tmi, current_day, current_year)
    % DESCRIPTION: Read data from TMI 1B11 File
    % param file_tmi: path to TMI Orbit File
    % return time: time vector of readings
    file_tmi = sprintf('%s%s', dir_tmi, name_tmi);
    scan_hour = hdfread(file_tmi, '/Swath/ScanTime/Hour', 'FirstRecord',1);
    scan_min = hdfread(file_tmi, '/Swath/ScanTime/Minute', 'FirstRecord',1);
    scan_sec = hdfread(file_tmi, '/Swath/ScanTime/Second', 'FirstRecord',1);
    scan_day = hdfread(file_tmi, '/Swath/ScanTime/DayOfYear', 'FirstRecord',1);
   
    time = (double(scan_hour) + double(scan_min)/60 + double(scan_sec)/3600)';
    aDayAfter = logical(scan_day > current_day);
    aDayBefore = logical(scan_day < current_day);
    time = time + 24 .* aDayAfter' - 24 .* aDayBefore';
end