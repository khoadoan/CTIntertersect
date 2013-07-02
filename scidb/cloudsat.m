cd('C:\school\trmm-cs\scidb\hdf4conversion')
cloudsat_dir = 'C:\school\trmm-cs\scidb\hdf4conversion\CloudSat\*\hdf';
output = 'C:\school\trmm-cs\scidb\hdf4conversion\CloudSat\cloudsat.csv';
output_dir = 'C:\school\trmm-cs\scidb\hdf4conversion\CloudSat';

offset = 0;
for d=1:3
    %seconds = int64(offset + (d-1)*60*60*24);
    seconds = d;
    fprintf('%d\n', seconds);
    input_dir = regexprep(cloudsat_dir, '\*', sprintf('%03d', d));
    fprintf('Source DIR %s', input_dir);
    files = dir(input_dir);
    files = files(3:length(files));
    for i=1:length(files)
       %csv_filename = cloudsats2csv(directory, files(i).name, offset, output); 
       csv_filename = cloudsat2csv(input_dir, output_dir, files(i).name, seconds); 
    end
end
