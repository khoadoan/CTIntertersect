data_directory = 'C:/school/operation/data/';
currentYear = '2007';
startDay = '2';
endDay = '2';
iTimeDelta = '0.25';
iGeoDelta = '0.1';
sat_index_interval = '300';
    % DESCRIPTION: find intersections and output data
    % param data_directory: directory containing data files
    % param currentYear: year of data to be processed
    % param startDay: start from this day
    % param endDay: end at this day
    % param iTimeDelta: passing time interval of TRMM and CS for a valid center of intersection.
    % param iGeoDelta: a distance that is used to speed up the calculation
    % return VOID
    
    %% PREPROCESS PARAMETERS
    % Giving 2 options to run this function, as compiled executable or from
    % another matlab function
    if ischar(currentYear)
        currentYear = str2num(currentYear);
    end
    
    if ischar(startDay)
        startDay = str2num(startDay);
    end
    
    if ischar(endDay)
        endDay = str2num(endDay);
    end
    
    if ischar(iTimeDelta)
        iTimeDelta = str2double(iTimeDelta);
    end
    
    if ischar(iGeoDelta)
        iGeoDelta = str2double(iGeoDelta);
    end
    
    if ischar(sat_index_interval)
        sat_index_interval = str2num(sat_index_interval);
    end
    
    
    %% CONSTANTS
    cs_version = '2B-GEOPROF';
    amsre_version = '002';
    trmm_1C21 = '1C21';
    trmm_2A23 = '2A23';
    trmm_2A25 = '2A25';
    tmi_1B11 = '1B11';
    tmi_2A12 = '2A12';
    int_version = '0.0';

    %% Collect each cs day and corresponding trmm into batches
    for dayOfYear = startDay:endDay
        fprintf('Processing day %d of year %d\n', dayOfYear, currentYear);
        try
            %INITIALIZE VARIABLES
            cs_directory = sprintf('%s%s/%4d/%03d/%s/', data_directory, 'CloudSat', currentYear, dayOfYear, cs_version);
            trmm_directory = sprintf('%s%s/%s/%4d/%03d/', data_directory, 'TRMM', trmm_1C21, currentYear, dayOfYear);
            tmi_directory = sprintf('%s%s/%s/%4d/%03d/', data_directory, 'TMI', tmi_1B11, currentYear, dayOfYear);
            amsre_directory = sprintf('%s%s/%4d/%03d/%s/', data_directory, 'AMSR-E', currentYear, dayOfYear, amsre_version);
            output_dir = sprintf('%s%s/%4d/%03d/%s/', data_directory, 'CS-TRMM-Intersect', currentYear, dayOfYear, int_version);

            fprintf('Directories \n\t %s\n\t %s\n\t %s\n\t %s\n\t %s\n', cs_directory, trmm_directory, tmi_directory, amsre_directory, output_dir);

            % Extract file information from the 2 directories
            cs_filenames = dir(sprintf('%s*.hdf', cs_directory));
            %cs_filenames = cs_filenames(3:length(cs_filenames));
            cs_files_count = numel(cs_filenames);

            amsre_filenames = dir(sprintf('%s*.hdf', amsre_directory));
            %cs_filenames = cs_filenames(3:length(cs_filenames));
            amsre_files_count = numel(amsre_filenames);

            trmm_filenames = dir(sprintf('%s*.HDF', trmm_directory));
            %trmm_filenames = trmm_filenames(3:length(trmm_filenames));
            trmm_files_count = length(trmm_filenames);

            tmi_filenames = dir(sprintf('%s*.HDF', tmi_directory));
            %trmm_filenames = trmm_filenames(3:length(trmm_filenames));
            tmi_files_count = length(tmi_filenames);

            % Find intersections
            intersections = struct('cs_filename', {}, 'trmm_filename', {}, 'curtain_indexes', [3 2], 'cs_trmm_intersection', [1 7], 'tmi_filename', {}, 'amsr_e_filename', {}, 'amsr_e_tmi', {});
            intersections = find_intersection(intersections, trmm_directory, trmm_filenames, cs_directory, cs_filenames, iTimeDelta, iGeoDelta, @read_trmm, @read_cs, currentYear, dayOfYear);

            intersections = find_intersection_swath(intersections, tmi_directory, amsre_directory, tmi_filenames, amsre_filenames, iTimeDelta, iGeoDelta, @read_tmi, @read_tmi_time, @read_amsr_e, @read_amsr_e_time, currentYear, dayOfYear, sat_index_interval);

            % Making Directory
            system(sprintf('mkdir -p %s', output_dir));

            % Write output
            write_all_output(intersections, output_dir);
        catch err
            fprintf('Error in Processing day %d of year %d\n', dayOfYear, currentYear);
            fprintf('%s', getReport(err, 'extended'));
        end
    end