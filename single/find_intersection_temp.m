function [ intersections ] = find_intersection_temp( sat1_directory, sat2_directory, iTimeDelta, iGeoDelta, read_sat1_file, read_sat2_file)
    % DESCRIPTION: find intersections of 2 satellites in 1 day
    % param sat1_directory: directory containing orbit files of satellite 1
    % param sat2_directory: directory containing orbit files of satellite 2
    % param iTimeDelta: TODO
    % param iGeoDelta: distance of 2 satellites that can be considered as an intersection
    % return intersections TODO
    
    % Save the reading orbits of satellite 1
    sat1_orbits = struct('filename', {}, 'latitude', {}, 'longitude', {}, 'time', {}, 'dayOfYear', {});
    % Save the intersection information TODO
    intersections = [];
    
    % Extract file information from the 2 directories
    sat2_filenames = dir(sat2_directory);
    sat2_filenames = sat2_filenames(3:length(sat2_filenames));
    sat2_files_count = numel(sat2_filenames);
    sat1_filenames = dir(sat1_directory);
    sat1_filenames = sat1_filenames(3:length(sat1_filenames));
    sat1_files_count = length(sat1_filenames);

    % Read data from sattellite 1
    for sat1_orbit_index = 1: sat1_files_count,
        sat1_file = sprintf('%s%s', sat1_directory, sat1_filenames(sat1_orbit_index).name);
        fprintf('%d: %s\n', sat1_orbit_index, sat1_file);
        [sat1_orbit_latitudes, sat1_orbit_longitudes, sat1_orbit_time] = read_sat1_file(sat1_directory, sat1_filenames(sat1_orbit_index).name, 61, 2010); %TODO: remove hard coding
        sat1_orbit_readings_count = length(sat1_orbit_time);
        sat1_orbits(sat1_orbit_index).filename = sat1_file;
        sat1_orbits(sat1_orbit_index).latitude = sat1_orbit_latitudes;
        sat1_orbits(sat1_orbit_index).longitude = sat1_orbit_longitudes;
        sat1_orbits(sat1_orbit_index).time = sat1_orbit_time;
        sat1_orbits(sat1_orbit_index).count = sat1_orbit_readings_count;
        fprintf('\t\tTime Frame from %d to %d\n', sat1_orbit_time(1), sat1_orbit_time(sat1_orbit_readings_count));
    end
    
    for sat2_orbit_index=1:sat2_files_count
        sat2_file = sprintf('%s%s', sat2_directory, sat2_filenames(sat2_orbit_index).name);
        fprintf('%d: %s\n', sat2_orbit_index, sat2_file);
        [sat2_orbit_latitude, sat2_orbit_longitude, sat2_orbit_time] = read_sat2_file(sat2_directory, sat2_filenames(sat2_orbit_index).name, 61); %PARAM
        sat2_readings_count = length(sat2_orbit_time);

        fprintf('\tTime Frame from %d to %d\n', sat2_orbit_time(1), sat2_orbit_time(sat2_readings_count));
        

        % Preprocessing this CS Orbit
        % 1) Keep only the ones within Latitudes of TRMM - expected 3
        % strips per CS Orbit
        sat2_orbit_latitude_test = logical(-40 < sat2_orbit_latitude & sat2_orbit_latitude < 40); %PARAM
        cs_boundary_points = find(sat2_orbit_latitude_test(1, 1:sat2_readings_count-1) - sat2_orbit_latitude_test(1, 2:sat2_readings_count));
        cs_boundary_points(2:2:length(cs_boundary_points)) = cs_boundary_points(2:2:length(cs_boundary_points)) + 1;
        cs_boundary_points = [1, cs_boundary_points, sat2_readings_count];
        sat2_strips_count = length(cs_boundary_points) / 2;
        
        % Find Intersections with this Satellite 2 Orbit
        for sat1_orbit_index = 1: sat1_files_count,
            % Initialize TRMM Orbit variables
            sat1_orbit = sat1_orbits(sat1_orbit_index);
            sat1_orbit_time = sat1_orbit.time;
            sat1_orbit_latitude = sat1_orbit.latitude(:, 25);
            sat1_orbit_longitude = sat1_orbit.longitude(:, 25);
            sat1_orbit_reading_counts = length(sat1_orbit_time);
            
            % IMPROVEMENT: probably we can start in the middle here (like a
            % binary search kind of way)
            for i = 1:sat2_strips_count
                % Intialize CS Strip variables
                sat2_strip_start_index = cs_boundary_points((i-1)*2 + 1);
                sat2_strip_end_index = cs_boundary_points(i*2);
                
                % When this strip overlaps with this Satellite 1 Orbit with
                % respect to Time
                intersection_info = [9999, 0, 0];
                if (sat1_orbit_time(1) - iTimeDelta <= sat2_orbit_time(sat2_strip_start_index) && sat2_orbit_time(sat2_strip_start_index) < sat1_orbit_time(sat1_orbit_reading_counts) + iTimeDelta) ||...
                    (sat1_orbit_time(sat1_orbit_reading_counts) - iTimeDelta <= sat2_orbit_time(sat2_strip_end_index) && sat2_orbit_time(sat2_strip_end_index) < sat1_orbit_time(sat1_orbit_reading_counts) + iTimeDelta)
                    % Find the nearest points between this strip and
                    % Satellite 1 Orbit
                    for sat2_reading_index=sat2_strip_start_index:sat2_strip_end_index
                        [min_distance, min_sat1_index] = min(lldist(sat1_orbit_latitude, sat1_orbit_longitude, ...
                        sat2_orbit_latitude(sat2_reading_index), ...
                        sat2_orbit_longitude(sat2_reading_index)));
                        if (min_distance <= iGeoDelta && ...
                            min_distance < intersection_info(1)) ...
                            intersection_info = [min_distance, min_sat1_index, sat2_reading_index];
                        end
                    end
                    
                    % Then if the center of intersection satisfies the time
                    % condition, then keep it, otherwise, reset it
                    if intersection_info(2) > 0 && abs(sat1_orbit_time(intersection_info(2)) - sat2_orbit_time(intersection_info(3))) > iTimeDelta
                        intersection_info = [9999, 0, 0];
                    end
                end
                %Found an Intersection
                if intersection_info(2) > 0
                    intersections =  [intersections; intersection_info(1), sat1_orbit_time(intersection_info(2)), sat2_orbit_time(intersection_info(3)),...
                                                     sat1_orbit_latitude(intersection_info(2)), sat1_orbit_longitude(intersection_info(2)), ...
                                                     sat2_orbit_latitude(intersection_info(3)), sat2_orbit_longitude(intersection_info(3)), ...
                                                     sat1_orbit_index, intersection_info(2), ...
                                                     sat2_orbit_index, intersection_info(3)];
                    fprintf('DIST=%f for INFO TIME (%f, %f), LAT (%f, %f), LON (%f, %f)\n', intersection_info(1),...
                        sat1_orbit_time(intersection_info(2)), sat2_orbit_time(intersection_info(3)),...
                        sat1_orbit_latitude(intersection_info(2)), sat2_orbit_latitude(intersection_info(3)),...
                        sat1_orbit_longitude(intersection_info(2)), sat2_orbit_longitude(intersection_info(3)));
                end
            end
        end
    end
end


