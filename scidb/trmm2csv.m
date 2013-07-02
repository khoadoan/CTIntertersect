function [ new_filepath ] = trmm2csv(src_dir, dest_dir, filename, d)

R = 6353000;

filepath = sprintf('%s/%s', src_dir, filename);
disp(filepath);

fileinfo = hdfinfo(filepath);

geolocation_fields = fileinfo.Vgroup(3);
geolocation_sds = struct('name', {}, 'data', {});
for i=1:4
    field_info = geolocation_fields.SDS(i);
    geolocation_sds(i).data = hdfread(field_info);
    geolocation_sds(i).name = field_info.Name;
end

if exist(dest_dir, 'file') == 0
    mkdir(dest_dir);
end

new_filename = regexprep(filename, '\.(hdf|HDF)', '.csv');
new_filepath = sprintf('%s/%s', dest_dir, new_filename);
disp(new_filepath)

% csvwrite_with_headers(new_filename, flatten(geolocation_sds(2).data,...
%                                  geolocation_sds(3).data,...
%                                  geolocation_sds(1).data,...
%                                  geolocation_sds(4).data),...
%                                  {'latitude', 'longitude', 'time', 'systemNoise'});

latitude = hdfread(filepath, '/Swath/Latitude');
[m, n] = size(latitude);
longitude = hdfread(filepath, '/Swath/Longitude');
t = hdfread(filepath, '/Swath/scanTime_sec');
t = t';
d = d * ones(m, 1);
systemNoise = hdfread(filepath, '/Swath/systemNoise');

% data = zeros(m*n, 6);
% for i=1:n
%     data(m*(i-1)+1:m*i, :) = [latitude(:, i), longitude(:, i), ones(m, 1)*i, time_offset, scanTime_sec, systemNoise(:, i)];
% end

xyz = latlon2xyz(latitude(:,25), longitude(:,25), R);

csvwrite_with_headers(new_filepath, [xyz, d, t, systemNoise(:, 25)],...
                                 {'x', 'y', 'z', 'd', 't', 'systemNoise'});

end

    