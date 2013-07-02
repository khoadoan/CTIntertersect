cd('C:\school\trmm-cs\scidb\hdf4conversion');
trmm_dir = 'C:\school\trmm-cs\scidb\hdf4conversion\TRMM\*\hdf';
output = 'C:\school\trmm-cs\scidb\hdf4conversion\TRMM\trmm.csv';
output_dir = 'C:\school\trmm-cs\scidb\hdf4conversion\TRMM';
offset = 0;

for d=1:3
    %seconds = offset + (d-1)*60*60*24;
    seconds = d;
    input_dir = regexprep(trmm_dir, '\*', sprintf('%03d', d));
    fprintf('Source DIR %s', input_dir);
    files = dir(input_dir);
    files = files(3:length(files));
    for i=1:length(files)
       csv_filename = trmm2csv(input_dir, output_dir, files(i).name, seconds); 
    end
end

