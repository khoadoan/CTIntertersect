function [latitude, longitude, time] = read_cs( dir_cs, name_cs, dayOfYear, currentYear )
    % DESCRIPTION: Read data from TRMM Orbit File
    % param file_cs: path to TRMM Orbit File
    % return latitude: latitude vector of readings
    % return longitude: longitude vector of readings
    % return time: time vector of readings
    file_cs = sprintf('%s%s', dir_cs, name_cs);
    UTC_start = hdfread(file_cs,'/2B-GEOPROF/Geolocation Fields/UTC_start', 'Fields', 'UTC_start', 'FirstRecord',1 ,'NumRecords',1);
    time = hdfread(file_cs, '/2B-GEOPROF/Geolocation Fields/Profile_time', 'Fields', 'Profile_time', 'FirstRecord',1);
    latitude = hdfread(file_cs,'/2B-GEOPROF/Geolocation Fields/Latitude', 'Fields', 'Latitude', 'FirstRecord',1);
    longitude = hdfread(file_cs,'/2B-GEOPROF/Geolocation Fields/Longitude', 'Fields', 'Longitude', 'FirstRecord',1);
    time = cell2mat(time);
    latitude = cell2mat(latitude);
    longitude = cell2mat(longitude);
    UTC_start = double(cell2mat(UTC_start)) / 3600;
    
    time = double(time) / 3600 + UTC_start;
    
    % Pattern to extract: yyyydddhhmmss
    pattern = '(\d\d\d\d)(\d\d\d)(\d\d)(\d\d)(\d\d)';
    tokens = regexp(name_cs, pattern, 'tokens');
    
    % When day_of_year is less than today
    if str2num(tokens{1,1}{2}) < dayOfYear
        time = time - 24;
    end
end

