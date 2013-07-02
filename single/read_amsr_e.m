function [latitude, longitude, time] = read_amsr_e( dir, file_name, current_day, current_year )
    % DESCRIPTION: Read data from AMSR-E Orbit File
    % param dir: path to directory containing the file
    % param file_name: name of the file
    % param current_day: current_day of the year
    % param year: year
    % return latitude: latitude vector of readings
    % return longitude: longitude vector of readings
    % return time: time vector of readings

    file = sprintf('%s%s', dir, file_name);
    time = hdfread(file, '/Low_Res_Swath/Geolocation Fields/Time', 'Fields', 'Time');
    time = cell2mat(time);
    % Convert to UTC Time of Day
    time = tai932utc(time);
    
    latitude = hdfread(file,'/Low_Res_Swath/Geolocation Fields/Latitude');
    longitude = hdfread(file,'/Low_Res_Swath/Geolocation Fields/Longitude');
    
    % Pattern to extract: yyyydddhhmmss
    pattern = '(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)';
    tokens = regexp(file_name, pattern, 'tokens');
    file_year = str2num(tokens{1,1}{1});
    file_day = date2day(file_year, str2num(tokens{1,1}{2}), str2num(tokens{1,1}{3}));
    
    % When current_day_of_year is less than tocurrent_day
    if file_day < current_day || (file_year < current_year && file_day > current_day) 
        time = time - 24;
    end
end

