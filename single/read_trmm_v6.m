function [latitude, longitude, time] = read_trmm_v6( dir_trmm, name_trmm, day, year )
    % DESCRIPTION: Read data from TRMM Orbit File
    % param file_trmm: path to TRMM Orbit File
    % return latitude: latitude matrix of readings x scans
    % return longitude: longitude matrix of readings x scans
    % return time: time vector of readings
    file_trmm = sprintf('%s%s', dir_trmm, name_trmm);
    geolocation = hdfread(file_trmm, '/DATA_GRANULE/SwathData/geolocation');
    scan_time =  hdfread(file_trmm, '/DATA_GRANULE/SwathData/scan_time', 'Fields', 'scanTime');
    scan_time = cell2mat(scan_time);
    
    [ yyyy, mm, dd ] = parse_trmm_filename(name_trmm);
    dayOfYear = date2day(yyyy, mm, dd);
    
    latitude = geolocation(:, :, 1);
    longitude = geolocation(:, :, 2);
    
    time = scan_time ./ 3600;
    scan_length = length(time);
    % This makes one assumption: processing is done in 1 day only
    % 2 cases: from previous day and span next day
    if time(1) > 22 && time(scan_length) < 2 % span next day
        previous_day_indices = logical(time > 22);
        time = time - previous_day_indices * 24;
    elseif time(1) < 2 && time(scan_length) > 22 % from previous day
        next_day_indices = logical(time < 2);
        time = time + next_day_indices * 24;        
    end
end

