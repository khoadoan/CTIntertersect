function [ new_filepath ] = cloudsat2csv( src_dir, dest_dir, filename, time_offset)

R = 6353000;

filepath = sprintf('%s/%s', src_dir, filename);
disp(filepath);
% fileinfo = hdfinfo(filepath);
% 
% geolocation_fields = fileinfo.Vgroup.Vgroup(1);
% geolocation_sds = struct('name', {}, 'data', {});
% for i=1:length(geolocation_fields.SDS)
%     field_info = geolocation_fields.SDS(i);
%     geolocation_sds(i).data = hdfread(field_info);
%     geolocation_sds(i).name = field_info.Name;
% end
% 
% geolocation_vdata = struct('name', {}, 'data', {});
% for i=1:length(geolocation_fields.Vdata)
%     field_info = geolocation_fields.Vdata(i);
%     geolocation_vdata(i).data = cell2mat(hdfread(field_info, 'Fields', field_info.Fields.Name));
%     data_size = size(geolocation_vdata(i).data);
%     if data_size(1) < data_size(2)
%         geolocation_vdata(i).data = geolocation_vdata(i).data';
%     end
%     geolocation_vdata(i).info = field_info.Name;
% end

if exist(dest_dir, 'file') == 0
    mkdir(dest_dir);
end

new_filename = regexprep(filename, '\.hdf', '.csv');
new_filepath = sprintf('%s/%s', dest_dir, new_filename);
disp(new_filepath)

% csvwrite_with_headers(new_filepath, [geolocation_vdata(4).data, geolocation_vdata(5).data, ...
%                                  geolocation_vdata(1).data + geolocation_vdata(2).data, ...
%                                  geolocation_sds(1).data(:, 1)], ...
%                                  {'latitude', 'longitude', 'time', 'Height'});

UTC_start = hdfread(filepath, '2B-GEOPROF', 'Fields', 'UTC_start');
Profile_time = hdfread(filepath, '2B-GEOPROF', 'Fields', 'Profile_time');

latitude = hdfread(filepath, '2B-GEOPROF', 'Fields', 'Latitude');
latitude = latitude';
longitude = hdfread(filepath, '2B-GEOPROF', 'Fields', 'Longitude');
longitude = longitude';
day_time = UTC_start + Profile_time;
day_time = day_time';
height = hdfread(filepath, '2B-GEOPROF', 'Fields', 'Height');

[xyz] = latlon2xyz(latitude, longitude, R);

csvwrite_with_headers(new_filepath, [xyz, time_offset * ones(length(day_time),1), day_time, height(:, 1)], ...
                                 {'x', 'y', 'z', 'd', 't', 'Height'});

end