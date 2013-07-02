iTimeDelta = 1/4;
iGeoDelta = 1/10;
current_year = 2007;
current_day = 2;
data_directory = 'C:/school/matlab/school-nasa-intersect/data/';

cs_directory = sprintf('%s%s/%4d/%03d/%s/', data_directory, 'CloudSat', current_year, current_day,  'R05'); %2B-GEOPROF change to your directory.
trmm_directory = sprintf('%s%s/%4d/%03d/', data_directory, 'TRMM/1C21', current_year, current_day); % 1B21 change to your directory.
tmi_directory  = sprintf('%s%s/%4d/%03d/', data_directory, 'TMI/1B11', current_year, current_day);
amsr_e_directory  = sprintf('%s%s/%4d/%03d/%s/', data_directory, 'AMSR-E', current_year, current_day, '002');

output_dir = sprintf('%s%s/%4d/%03d/', data_directory, 'Intersect', current_year, current_day);

% Extract file information from the 2 directories
cs_filenames = dir(sprintf('%s*.HDF', cs_directory));
cs_filenames = cs_filenames(3:length(cs_filenames));
cs_files_count = numel(cs_filenames);
tmi_filenames = dir(sprintf('%s*.HDF', tmi_directory));
tmi_filenames = tmi_filenames(3:length(tmi_filenames));
amsr_e_filenames = dir(sprintf('%s*.HDF', amsr_e_directory));
amsr_e_filenames = amsr_e_filenames(3:length(amsr_e_filenames));
trmm_filenames = dir(sprintf('%s*.HDF', trmm_directory));
trmm_filenames = trmm_filenames(3:length(trmm_filenames));
trmm_files_count = length(trmm_filenames);
sat_index_interval = 300;

% Find Intersections
intersections = struct('cs_filename', {}, 'trmm_filename', {}, 'curtain_indexes', [3 2], 'cs_trmm_intersection', [1 7], 'tmi_filename', {}, 'amsr_e_filename', {}, 'amsr_e_tmi', {});
intersections = find_intersection(intersections, trmm_directory, cs_directory, cs_filenames, trmm_filenames, iTimeDelta, iGeoDelta, @read_trmm, @read_cs, current_year, current_day);
intersections = find_intersection_swath(intersections, tmi_directory, amsr_e_directory, tmi_filenames, amsr_e_filenames, iTimeDelta, iGeoDelta, @read_tmi, @read_tmi_time, @read_amsr_e, @read_amsr_e_time, current_year, current_day, sat_index_interval);

% Write Output
sample_cs_file = 'C:\school\matlab\data\CS\HDF\2007002013457_03622_CS_2B-GEOPROF_GRANULE_B11_R05_E02.hdf';
