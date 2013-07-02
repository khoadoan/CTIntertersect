function [ yyyy, dd, hh, mm ] = parse_date1( file_name )
    % Parse Date and Time in a Filename with format yyyymmddhhmm
    pattern = '(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)';
    tokens = regexp(file_name, pattern, 'tokens');
    yyyy = str2num(tokens{1,1}{1});
    dd = date2day(file_year, str2num(tokens{1,1}{2}), str2num(tokens{1,1}{3}));
    hh = str2num(tokens{1,1}{4});
    mm = str2num(tokens{1,1}{5});
end

