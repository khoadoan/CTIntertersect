function [ intersections ] = find_intersection(intersections, trmm_directory, trmm_filenames, cs_directory, cs_filenames, iTimeDelta, iGeoDelta, read_trmm_file, read_cs_file, year, day)
    % DESCRIPTION: find intersections of 2 satellites in 1 day
    % param trmm_directory: directory containing orbit files TRMM
    % param trmm_filenames: filenames of TRMM orbits in TRMM directory
    % param cs_directory: directory containing orbit files of CloudSat
    % param cs_filenames: filenames of CloudSat orbits in CloudSat directory
    % param iTimeDelta: passing time interval of TRMM and CS for a valid
    % center of intersection.
    % param iGeoDelta: a distance that is used to speed up the calculation
    % of intersection.
    % param year: current year of prorcessing
    % param day: current day of processing
    % return intersections
    
    %% PREPROCESSING
    cs_files_count = numel(cs_filenames);
    trmm_files_count = numel(trmm_filenames);
    
    fprintf('Processing %d CloudSat orbits and %d TRMM Orbits\n', cs_files_count, trmm_files_count);
    
    % Save the reading orbits of trmm
    trmm_orbits = struct('filename', {}, 'latitude', {}, 'longitude', {}, 'time', {}, 'dayOfYear', {});
    % The index of the current found intersection below
    iIndex = 1;
    
    %% READ TRMM DATA
    % Read data from trmm orbit
    for trmm_orbit_index = 1: trmm_files_count,
        trmm_filename = trmm_filenames(trmm_orbit_index).name;
        trmm_file = sprintf('%s%s', trmm_directory, trmm_filename);
        
        fprintf('%d: READ %s\n', trmm_orbit_index, trmm_file);

        [trmm_orbit_latitudes, trmm_orbit_longitudes, trmm_orbit_time] = read_trmm_file(trmm_directory, trmm_filename, day, year); %TODO: remove hard coding
        trmm_orbit_readings_count = length(trmm_orbit_time);
        trmm_orbits(trmm_orbit_index).filename = trmm_file;
        trmm_orbits(trmm_orbit_index).latitude = trmm_orbit_latitudes;
        trmm_orbits(trmm_orbit_index).longitude = trmm_orbit_longitudes;
        trmm_orbits(trmm_orbit_index).time = trmm_orbit_time;
        trmm_orbits(trmm_orbit_index).count = trmm_orbit_readings_count;
        fprintf('\t\tTRMM Orbit from %4.2f to %4.2f (in hours)\n', trmm_orbit_time(1), trmm_orbit_time(trmm_orbit_readings_count));
    end
    
    %% READ CLOUDSAT DATA AND FIND INTERSECTION 
    % Read CloudSat orbit then find intersection of this orbit with TRMM 
    % if there is any
    for cs_orbit_index=1:cs_files_count
        cs_filename = cs_filenames(cs_orbit_index).name;
        cs_file = sprintf('%s%s', cs_directory, cs_filename);
        
        fprintf('%d: READ %s\n', cs_orbit_index, cs_file);
        
        [cs_orbit_latitude, cs_orbit_longitude, cs_orbit_time] = read_cs_file(cs_directory, cs_filename, day); %PARAM
        cs_readings_count = length(cs_orbit_time);

        fprintf('\t CloudSat Orbit from %4.2f to %4.2f (in hours).\n', cs_orbit_time(1), cs_orbit_time(cs_readings_count));

        %% Preprocessing this CS Orbit
        % We don't want to look at the whole orbit, only in the "most
        % probable" regions:
        % 1) Keep only the ones within Latitudes of TRMM - expected 3
        % sets of contiguous scans (called strip) per CS Orbit 
        cs_orbit_latitude_test = logical(-40 < cs_orbit_latitude & cs_orbit_latitude < 40); %TODO: parameterize
        % Since each CloudSat orbit starts and ends at around the equator,
        % the above test will give us 3 runs of continus 1's
        cs_boundary_points = find(cs_orbit_latitude_test(1, 1:cs_readings_count-1) - cs_orbit_latitude_test(1, 2:cs_readings_count));
        cs_boundary_points(2:2:length(cs_boundary_points)) = cs_boundary_points(2:2:length(cs_boundary_points)) + 1;
        cs_boundary_points = [1, cs_boundary_points, cs_readings_count];
        cs_strips_count = length(cs_boundary_points) / 2;
        
        %% Find Intersections
        for trmm_orbit_index = 1: trmm_files_count,
            % Initialize TRMM Orbit variables
            trmm_orbit = trmm_orbits(trmm_orbit_index);
            trmm_orbit_file = trmm_orbit.filename;
            trmm_orbit_time = trmm_orbit.time;
            trmm_orbit_latitude = trmm_orbit.latitude;
            trmm_orbit_longitude = trmm_orbit.longitude;
            trmm_orbit_reading_counts = length(trmm_orbit_time);
            
            % Currently the idea is to find the intersection of CS with the
            % 25th ray of TRMM for this section by scanning.
            % IMPROVEMENT: probably we can start in the middle here (like a
            % binary search kind of way)
            for i = 1:cs_strips_count
                % Intialize CS Strip variables
                cs_strip_start_index = cs_boundary_points((i-1)*2 + 1);
                cs_strip_end_index = cs_boundary_points(i*2);
                
                % Contains the information as a triplet (distance, index of
                % trmm, index of cs) for the center of intersection and the
                % 2 points specifying the intersect curtain.
                intersection_info = [9999, 0, 0, 9999, 0, 0, 9999, 0, 0];
                % Check if this TRMM orbit and this CS orbit are paired
                if (trmm_orbit_time(1) - iTimeDelta <= cs_orbit_time(cs_strip_start_index) && cs_orbit_time(cs_strip_start_index) < trmm_orbit_time(trmm_orbit_reading_counts) + iTimeDelta) ||...
                    (trmm_orbit_time(trmm_orbit_reading_counts) - iTimeDelta <= cs_orbit_time(cs_strip_end_index) && cs_orbit_time(cs_strip_end_index) < trmm_orbit_time(trmm_orbit_reading_counts) + iTimeDelta)
                    % Find the nearest points between this strip and
                    % TRMM Orbit
                    for cs_reading_index=cs_strip_start_index:cs_strip_end_index
                        stop_changing = true;
                        % Distance to Center Ray
                        [min_distance, min_trmm_index] = min(lldist(trmm_orbit_latitude(:, [1 25 49]), trmm_orbit_longitude(:, [1 25 49]), ...
                        cs_orbit_latitude(cs_reading_index), ...
                        cs_orbit_longitude(cs_reading_index)));
                        
                        % This finds the center of intersection
                        if min_distance(2) <= iGeoDelta && min_distance(2) < intersection_info(1)
                            intersection_info(1:3) = [min_distance(2), min_trmm_index(2), cs_reading_index];
                        end
                        
                        % This finds the 1st point of the curtain
                        if min_distance(1) < intersection_info(4)
                            stop_changing = false;
                            if min_distance(1) < iGeoDelta 
                                intersection_info(4:6) = [min_distance(1), min_trmm_index(1), cs_reading_index];
                            end
                        end
                        % This find the second point of the curtain
                        if min_distance(3) < intersection_info(7)
                            stop_changing = false;
                            if min_distance(3) < iGeoDelta 
                                intersection_info(7:9) = [min_distance(3), min_trmm_index(3), cs_reading_index];
                            end
                        end
                        
                        % the min_distance between cs scan and
                        % the first and last ray of a trmm scan will be
                        % changing until it reach a minimum, which we can
                        % then stop and proceed to the next one.
                        if stop_changing
                            break;
                        end
                    end
                    
                    % Then if the center of intersection does not satisfy
                    % the time condition, reset it
                    if intersection_info(2) > 0 && abs(trmm_orbit_time(intersection_info(2)) - cs_orbit_time(intersection_info(3))) > iTimeDelta
                        intersection_info = [9999, 0, 0, 9999, 0, 0, 9999, 0, 0];
                    end
                end
                
                % Found an Intersection
                if intersection_info(2) > 0
                    intersections(iIndex).cs_filename = cs_file;
                    intersections(iIndex).trmm_filename = trmm_orbit_file;
                    cs_curtain_length = abs(intersection_info(9)-intersection_info(6)) + 1;
                    pairs = zeros(cs_curtain_length, 3);
                    if intersection_info(6) > intersection_info(9)
                        cs_scan_start = intersection_info(9); 
                        cs_scan_end = intersection_info(6);
                        pairs(1, :) = [intersection_info(9), intersection_info(8), 49];
                        pairs(cs_curtain_length, :) = [intersection_info(6), intersection_info(5), 1];
                    else     
                        cs_scan_start = intersection_info(6); 
                        cs_scan_end = intersection_info(9);
                        pairs(1, :) = [intersection_info(6), intersection_info(5), 1];
                        pairs(cs_curtain_length, :) = [intersection_info(9), intersection_info(8), 49];
                    end
                    
                    trmm_curtain_range = min(intersection_info(5), intersection_info(8)):max(intersection_info(5), intersection_info(8));
                    
                    cs_curtain_index = 2;
                    for cs_scan_index = cs_scan_start+1: cs_scan_end-1
                        [ray_min, ray_min_index] = min(lldist(trmm_orbit_latitude(trmm_curtain_range, :), trmm_orbit_longitude(trmm_curtain_range, :), ...
                                                              cs_orbit_latitude(cs_scan_index), cs_orbit_longitude(cs_scan_index)), [], 2);
                        [scan_min, scan_min_index] = min(ray_min);
                        pairs(cs_curtain_index, :) = [cs_scan_index, trmm_curtain_range(scan_min_index), ray_min_index(scan_min_index)];
                        cs_curtain_index = cs_curtain_index + 1;
                    end
                    
                    intersections(iIndex).curtain_indexes = [intersection_info(3), intersection_info(2), 25; ... % Center of intersection, trmm and clousat indices
                                                             pairs]; % All Curtain pairs

                    intersections(iIndex).cs_trmm_intersection =     [intersection_info(1), ... % distance of trmm and cs at center
                                                     trmm_orbit_latitude(intersection_info(2), 25), trmm_orbit_longitude(intersection_info(2), 25), ... % lat and lon of trmm at center
                                                     cs_orbit_latitude(intersection_info(3)), cs_orbit_longitude(intersection_info(3)), ... % lat and lon of trmm at center
                                                     trmm_orbit_time(intersection_info(2)), cs_orbit_time(intersection_info(3))]; % Time at center of trmm and cloudsat
                    fprintf('FOUND INT: DIST=%f for TIME(%f, %f), LAT(%f, %f), LON(%f, %f)\n', intersection_info(1),...
                        trmm_orbit_time(intersection_info(2)), cs_orbit_time(intersection_info(3)),...
                        trmm_orbit_latitude(intersection_info(2), 25), cs_orbit_latitude(intersection_info(3)),...
                        trmm_orbit_longitude(intersection_info(2), 25), cs_orbit_longitude(intersection_info(3)));
                    iIndex = iIndex + 1;
                end
            end
        end
    end
end