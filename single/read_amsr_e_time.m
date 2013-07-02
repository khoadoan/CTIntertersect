function [amsr_time] = read_amsr_e_time( amsr_e_dir, amsr_e_filename, current_day, current_year)
    amsr_e_file = sprintf('%s%s', amsr_e_dir, amsr_e_filename);
    amsr_time = tai932utc(cell2mat(hdfread(amsr_e_file, '/Low_Res_Swath/Geolocation Fields/Time', 'Fields', 'Time')));
    amsr_time = amsr_time/3600; %Convert to hour
end