iTimeDelta = 1/4;
iGeoDelta = 1/10;
cs_directory = 'C:\school\matlab\data\CS\'; %2B-GEOPROF change to your directory.
trmm_directory = 'C:\school\matlab\data\v6\1C21\'; % 1B21 change to your directory.
output_dir = 'C:\school\matlab\data\CS_TR\';

currentYear = 2007;
startDay = 204;
endDay = 208;

% Extract file information from the 2 directories
cs_filenames = dir(cs_directory);
cs_filenames = cs_filenames(3:length(cs_filenames));
cs_files_count = numel(cs_filenames);

trmm_filenames = dir(trmm_directory);
trmm_filenames = trmm_filenames(3:length(trmm_filenames));
trmm_files_count = length(trmm_filenames);

%% Read temporal info of cs orbits
% [year, dayOfYear, hour]
cs_info = zeros(cs_files_count, 3);
for csFileNo = 1:cs_files_count
    filename = cs_filenames(csFileNo).name;
    % Pattern to extract: yyyydddhhmmss
    pattern = '(\d\d\d\d)(\d\d\d)(\d\d)(\d\d)(\d\d)';
    tokens = regexp(filename, pattern, 'tokens');
    cs_info(csFileNo, :) = [str2num(tokens{1}{1}), str2num(tokens{1}{2}), str2num(tokens{1}{3})];
end

%% Read temporal info of trmm orbits
% [year, dayOfYear, hour]
trmm_info = zeros(trmm_files_count, 3);
for trmmFileNo = 1:trmm_files_count
    filename = trmm_filenames(trmmFileNo).name;
    % Pattern to extract: yyyydddhhmmss
    pattern = '(\d\d)(\d\d)(\d\d)\.(\d\d\d\d\d)';
    tokens = regexp(filename, pattern, 'tokens');
    year = str2num(sprintf('20%s', tokens{1}{1}));
    dayOfYear = date2day(year, str2num(tokens{1}{2}), str2num(tokens{1}{3}));
    trmm_info(trmmFileNo, :) = [year, dayOfYear, str2num(tokens{1}{4})];
end

%% Collect each cs day and corresponding trmm into batches
for dayOfYear = startDay:endDay
    % Get the cs files for this day
    cs_files = cs_filenames(logical(cs_info(:, 2) == dayOfYear));
    
    % TODO: this need to be done more careful and exact
    % Get the trmm_files around this day: including 1 day before and after
    trmm_file_indices = find(logical(trmm_info(:, 2) == dayOfYear));
    if trmm_file_indices(length(trmm_file_indices)) ~= trmm_files_count
        trmm_file_indices = [trmm_file_indices; trmm_file_indices(length(trmm_file_indices)) + 1];
    end
    trmm_files = trmm_filenames(trmm_file_indices);
    
    % Find intersections
    intersections = find_intersection(trmm_directory, cs_directory, cs_files, trmm_files, iTimeDelta, iGeoDelta, @read_trmm_v6, @read_cs, currentYear, dayOfYear);
    
%     break;
    % Write output
    write_intersect_output_v6(intersections, output_dir);
end

info = zeros(length(intersections), 7);
for i = 1:length(intersections)
    info(i, :) = intersections(i).info;
end

plot(info(:, 3), info(:, 2), '.');
hold on;
plot(info(:, 5), info(:, 4), 'o', 'color', 'r');

% (info(:, 3)-info(:, 5)) .^2 + (info(:, 2) - info(:, 4)) .^ 2

for i=1:size(info, 1)
    text(double(info(i, 5)), double(info(i, 4)), num2str((info(i, 7) - info(i, 6)) * 60), 'HorizontalAlignment','center');
end
