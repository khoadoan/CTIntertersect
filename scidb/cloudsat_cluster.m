working_dir = '/gpfsm/dnb32/kdoan1/CINT/data/working/hdf/*.hdf';
output_dir = '/gpfsm/dnb32/kdoan1/CINT/data/working/csv/';

fprintf('Working on directory %s\n', working_dir);
files = dir(working_dir);
for i=1:length(files)
   csv_filename = cloudsat2csv(working_dir, output_dir, files(i).name);
   fprintf('\tTranslated %s to %s\n', files(i).name, csv_filename);
end

