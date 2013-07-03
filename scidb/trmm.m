cd('C:\school\CTIntertersect\scidb')
trmm_dir = 'C:\school\CTIntertersect\data\sample\TRMM\*\hdf';
output = 'C:\school\CTIntertersect\data\sample\TRMM\trmm.csv';
output_dir = 'C:\school\CTIntertersect\data\sample\TRMM';
offset = 0;

for d=1:3
    %seconds = offset + (d-1)*60*60*24;
    %seconds = d;
    input_dir = regexprep(trmm_dir, '\*', sprintf('%03d', d));
    fprintf('Source DIR %s', input_dir);
    files = dir(input_dir);
    files = files(3:length(files));
    for i=1:length(files)
       csv_filename = trmm2csv(input_dir, output_dir, files(i).name); 
    end
end

