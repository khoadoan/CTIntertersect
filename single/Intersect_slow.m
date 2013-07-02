iTimeDelta = 5/6;
iGeoDelta = 2.25;
cloudsat_directory = 'C:\school\data\cloudsat-2010-day-60\hdf\'; % change to your directory.
trmm_directory = 'C:\school\data\trmm-2010-day-60\hdf\'; % change to your directory.

trmm_orbits = struct('trmm_filename', {}, 'latitude', {}, 'longitude', {}, 'time', {}, 'dayOfYear', {});
intersections = struct('cs_filename', {}, 'tr_filename', {}, 'cs_time',{}, 'tr_time', {}, 'cs_lat', {}, 'tr_lat', {}, 'cs_lon', {}, 'tr_lon', {}, 'count', {});
filenames_cs = dir(cloudsat_directory);
filenames_cs = filenames_cs(3:length(filenames_cs));
num_cs_file = numel(filenames_cs);
filenames_trmm = dir(trmm_directory);
filenames_trmm = filenames_trmm(3:length(filenames_trmm));
num_trmm_file = length(filenames_trmm);

% Read TRMM Orbits
for num_trmm = 1: num_trmm_file,
    file_trmm = sprintf('%s%s', trmm_directory, filenames_trmm(num_trmm).name);
    fprintf('%d: %s\n', num_trmm, file_trmm);
    [Latitude_trmm, Longitude_trmm, trmm_time, dayOfYear] = read_trmm(file_trmm);   
    [trmm_readings_count, scans_count] = size(Latitude_trmm);
    trmm_orbits(num_trmm).trmm_filename = file_trmm;
    trmm_orbits(num_trmm).latitude = Latitude_trmm;
    trmm_orbits(num_trmm).longitude = Longitude_trmm;
    trmm_orbits(num_trmm).time = trmm_time;
    trmm_orbits(num_trmm).dayOfYear = dayOfYear;
    trmm_orbits(num_trmm).count = trmm_readings_count;
end

for num_cs=1:num_cs_file
    file_cs = sprintf('%s%s', cloudsat_directory, filenames_cs(num_cs).name);
    fprintf('%d: %s\n', num_cs, file_cs);
    [cs_time, cs_lat, cs_lon, UTC_start, UTC_end] = read_cs(file_cs);
    
    cs_readings_count = length(cs_time);
    
    % Preprocessing this CS Orbit
    % 1) Keep only the ones within Latitudes of TRMM
    cs_lat_test = logical(-40 < cs_lat & cs_lat < 40);
    cs_boundary_points = [1, find(cs_lat_test(1, 1:cs_readings_count-1) - cs_lat_test(1, 2:cs_readings_count)), cs_readings_count];
    cs_strips_count = length(cs_boundary_points) / 2;
    
    cs_time_min = cs_time - iTimeDelta;
    cs_time_max = cs_time + iTimeDelta;
    cs_lat_min = cs_lat - iGeoDelta;
    cs_lat_max = cs_lat + iGeoDelta;
    cs_lon_min = cs_lon - iGeoDelta;
    cs_lon_max = cs_lon + iGeoDelta;
    
    meet = 0;
    % Look for TRMM Orbits temporally overlapping this CS Orbit
    for num_trmm = 1: num_trmm_file,
        trmm_orbit = trmm_orbits(num_trmm);
        trmm_time = trmm_orbit.time;
        trmm_lat = trmm_orbit.latitude(:, 25);
        trmm_lon = trmm_orbit.longitude(:, 25);
        trmm_readings_count = trmm_orbit.count;
        
        for i = 1:cs_strips_count
            cs_strip_start_index = cs_boundary_points((i-1)*2 + 1);
            cs_strip_end_index = cs_boundary_points(i*2);
            
            %cs_strip_time = cs_time(cs_strip_start_index:cs_strip_end_index);
            if (trmm_time(1) < cs_time(cs_strip_start_index) && cs_time(cs_strip_start_index) < trmm_time(trmm_readings_count)) ...
                    || (trmm_time(1) < cs_time(cs_strip_end_index) && cs_time(cs_strip_end_index) < trmm_time(trmm_readings_count))
%                 pause;
                for cs_index = cs_strip_start_index:cs_strip_end_index
                    condition_test = logical(cs_time_min(cs_index) < trmm_time & trmm_time < cs_time_max(cs_index) ...
                                           & cs_lat_min(cs_index) < trmm_lat & trmm_lat < cs_lat_max(cs_index) ...
                                           & cs_lon_min(cs_index) < trmm_lon & trmm_lon < cs_lon_max(cs_index));
                    if meet == 0 && sum(condition_test) > 0
                        fprintf('intersection\n');
                        meet = 1;
                    end
                end
            end
        end
    end
end