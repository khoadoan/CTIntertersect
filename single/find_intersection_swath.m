function [ intersections ] = find_intersection_swath(cs_trmm_intersections, tmi_directory, amsr_e_directory, tmi_filenames, amsr_e_filenames, iTimeDelta, iGeoDelta, read_tmi_file, read_tmi_time, read_amsr_e_file, read_amsr_e_time, current_year, current_day, sat_index_interval)
    % DESCRIPTION: find intersections of 2 swath satellites given a point
    % within each intersection.
    % param tmi_dir: directory containing orbit files of satellite 1
    % param amsr_e_dir: directory containing orbit files of satellite 2
    % param iTimeDelta: TODO
    % param iGeoDelta: TODO
    % param year: current year
    % param day: current day
    % return intersections TODO
    TMI_SWATH_WIDTH = 208;
    AMSR_E_SWATH_WIDTH = 243;
    orbits = struct('amsr_e', {}, 'tmi', {});
    intersections = cs_trmm_intersections;
    
    % Proprocessing
    tmi_files_count = numel(tmi_filenames);
    amsr_e_files_count = numel(amsr_e_filenames);
    
    % Find AMSR-E Orbit File for each Intersection
    for amsr_e_orbit_index = 1: amsr_e_files_count,
        % If AMSR-E Orbit Time Interval contains the Intersection Point
        file_amsr_e = sprintf('%s%s', amsr_e_directory, amsr_e_filenames(amsr_e_orbit_index).name);
        amsr_time = read_amsr_e_time(amsr_e_directory, amsr_e_filenames(amsr_e_orbit_index).name, current_day, current_year);
        amsr_last_index = length(amsr_time);
        for i = 1:length(intersections)
            if intersections(i).cs_trmm_intersection(7) < amsr_time(amsr_last_index)
                % Found
                if intersections(i).cs_trmm_intersection(7) > amsr_time(1)
                    % Read Data From AMSR-E
                    [amsr_e_orbit_latitudes, amsr_e_orbit_longitudes, amsr_e_orbit_time] = read_amsr_e(amsr_e_directory, amsr_e_filenames(amsr_e_orbit_index).name, current_day, current_year);
                    orbits(i).amsr_e.latitude = amsr_e_orbit_latitudes;
                    orbits(i).amsr_e.longitude = amsr_e_orbit_longitudes;
                    orbits(i).amsr_e.time = amsr_e_orbit_time;
                    orbits(i).amsr_e.file = file_amsr_e;
                end
            else
                % If CS Time cannot be within this interval
                break;
            end
        end
    end
    
    % Similarly, Find TMI Orbit File for each Intersection
    for tmi_orbit_index = 1: tmi_files_count,
        % If AMSR-E Orbit Time Interval contains the Intersection Point
        file_tmi = sprintf('%s%s', tmi_directory, tmi_filenames(tmi_orbit_index).name);
        tmi_time = read_tmi_time(tmi_directory, tmi_filenames(tmi_orbit_index).name, current_day, current_year);
        tmi_last_index = length(tmi_time);
        
        for i = 1:length(intersections)
            if intersections(i).cs_trmm_intersection(7) < tmi_time(tmi_last_index)
                % Found
                if intersections(i).cs_trmm_intersection(7) > tmi_time(1)
                    % Read Data From AMSR-E
                    [tmi_orbit_latitudes, tmi_orbit_longitudes, tmi_orbit_time] = read_tmi(tmi_directory, tmi_filenames(tmi_orbit_index).name, current_day, current_year);
                    orbits(i).tmi.latitude = tmi_orbit_latitudes;
                    orbits(i).tmi.longitude = tmi_orbit_longitudes;
                    orbits(i).tmi.time = tmi_orbit_time;
                    orbits(i).tmi.file = file_tmi;
                end
            else
                % If CS Time cannot be within this interval
                break;
            end
        end
    end
    
    % Now For Each Intersection, Find the 4 Intersec Points Between TMI and
    % AMSR-E
    for iIndex = 1:length(intersections)
        intersection = intersections(iIndex);
        orbit = orbits(iIndex);
        intersections(iIndex).tmi_filename = orbit.tmi.file;
        intersections(iIndex).amsr_e_filename = orbit.amsr_e.file;
        
        % Find Scans of AMSR-E and TMI that're closest to CS
        dist1 = lldist(orbit.amsr_e.latitude, orbit.amsr_e.longitude, intersection.cs_trmm_intersection(4), intersection.cs_trmm_intersection(5));
        dist2 = lldist(orbit.tmi.latitude, orbit.tmi.longitude, intersection.cs_trmm_intersection(4), intersection.cs_trmm_intersection(5));
        [dist1, amsr_e_closest_index] = min(min(dist1, [], 2));
        [dist2, tmi_closest_index] = min(min(dist2, [], 2));
        
        if dist1 < iGeoDelta && dist2 < iGeoDelta
            % Scanning Along AMSR-E
            tmi_index_interval = max(1, tmi_closest_index-sat_index_interval):min(length(orbit.tmi.time), tmi_closest_index+sat_index_interval);
            amsr_e_index_interval = max(1, amsr_e_closest_index-sat_index_interval):min(length(orbit.tmi.time), amsr_e_closest_index+sat_index_interval);

            change = [0 0];
            prev_min_dist = [9999, 9999];
            tmi_block = [9999, 0];
            amsr_e_block = [9999, 0];
            for aIndex = amsr_e_index_interval
                [min_dist, min_index] = min(lldist(orbit.tmi.latitude(tmi_index_interval, [1, TMI_SWATH_WIDTH]), orbit.tmi.longitude(tmi_index_interval, [1, TMI_SWATH_WIDTH]), ...
                                                                      orbit.amsr_e.latitude(aIndex, 1), orbit.amsr_e.longitude(aIndex, 1)));
                if min_dist(1) < prev_min_dist(1)
                    prev_min_dist(1) = min_dist(1);
                    prev_min_index(1) = min_index(1);
                elseif change(1) == 0
                    change(1) = 1;
                    intersections(iIndex).amsr_e_tmi(sum(change),:) = [aIndex-1, 1, tmi_index_interval(prev_min_index(1)), 1];
                end

                if min_dist(2) < prev_min_dist(2)
                    prev_min_dist(2) = min_dist(2);
                    prev_min_index(2) = min_index(2);
                elseif change(2) == 0
                    change(2) = 1;
                    intersections(iIndex).amsr_e_tmi(sum(change),:) = [aIndex-1, 1, tmi_index_interval(prev_min_index(2)), TMI_SWATH_WIDTH];
                end
            end

            prev_min_dist = [9999, 9999];
            for aIndex = amsr_e_index_interval
                [min_dist, min_index] = min(lldist(orbit.tmi.latitude(tmi_index_interval, [1, TMI_SWATH_WIDTH]), orbit.tmi.longitude(tmi_index_interval, [1, TMI_SWATH_WIDTH]), ...
                                           orbit.amsr_e.latitude(aIndex, AMSR_E_SWATH_WIDTH), orbit.amsr_e.longitude(aIndex, AMSR_E_SWATH_WIDTH)));
                if min_dist(1) < prev_min_dist(1)
                    prev_min_dist(1) = min_dist(1);
                    prev_min_index(1) = min_index(1);
                elseif change(1) == 1
                    change(1) = 2;
                    intersections(iIndex).amsr_e_tmi(sum(change),:)= [aIndex-1, 1, tmi_index_interval(prev_min_index(1)), 1];
                end

                if min_dist(2) < prev_min_dist(2)
                    prev_min_dist(2) = min_dist(2);
                    prev_min_index(2) = min_index(2);
                elseif change(2) == 1
                    change(2) = 2;
                    intersections(iIndex).amsr_e_tmi(sum(change),:) = [aIndex-1, 1, tmi_index_interval(prev_min_index(2)), TMI_SWATH_WIDTH];
                end
            end
        end
    end
end


