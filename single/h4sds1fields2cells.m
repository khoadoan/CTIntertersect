function [ output ] = h4sds1fields2cells( filename, name, section, fields)
% Function to read HDF sds data and convert it to a cell
noOfFields = length(fields);
vstru = struct();
for i=1:noOfFields
    fname = fields{i};
%     fprintf('%s\t%s%s\n', filename, section, fname);
    fdata =  hdfread(filename, sprintf('%s%s', section, fname));
    eval(sprintf('vstru.%s = fdata;', fname));
end
output{1} = {name, vstru};
end



