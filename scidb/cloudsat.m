cd('C:\school\CTIntertersect\scidb')
cloudsat_dir = 'C:\school\CTIntertersect\data\sample\CloudSat\*\hdf';
output = 'C:\school\CTIntertersect\data\sample\CloudSat\cloudsat.csv';
output_dir = 'C:\school\CTIntertersect\data\sample\CloudSat';

offset = 0;
for d=1:3
    input_dir = regexprep(cloudsat_dir, '\*', sprintf('%03d', d));
    fprintf('Source DIR %s', input_dir);
    files = dir(input_dir);
    files = files(3:length(files));
    for i=1:length(files)
       csv_filename = cloudsat2csv(input_dir, output_dir, files(i).name); 
    end
end
