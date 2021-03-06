function [ new_filepath ] = trmm2csv(src_dir, dest_dir, filename)

% R = 6353000;

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

latitude = scale_latlon(hdfread(filepath, '/Swath/Latitude'));
longitude = scale_latlon(hdfread(filepath, '/Swath/Longitude'));
systemNoise = hdfread(filepath, '/Swath/systemNoise');
year = hdfread(filepath, '/Swath/ScanTime/Year')';
month = hdfread(filepath, '/Swath/ScanTime/Month')';
dayOfMonth = hdfread(filepath, '/Swath/ScanTime/DayOfMonth')';
hour = int64(hdfread(filepath, '/Swath/ScanTime/Hour'))';
minute = int64(hdfread(filepath, '/Swath/ScanTime/Minute'))';
second = int64(hdfread(filepath, '/Swath/ScanTime/Second'))';

dayOfYear = date2day(year, month, dayOfMonth);
secondFromStartOfDay = int64(hour*3600 + minute*60 + second);
[year, dayOfYear, time] = get_time(int64(year), dayOfYear, secondFromStartOfDay);
time = scale_time(time);

%xyz = latlon2xyz(latitude(:,25), longitude(:,25), R);


csvwrite_with_headers(new_filepath, [latitude(:, 25), longitude(:, 25), year, dayOfYear, time, systemNoise(:, 25)],...
                                 {'lat', 'lon', 'y', 'd', 't', 'systemNoise'});

end

    