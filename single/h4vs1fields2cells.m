function [ vlist ] = h4vs1fields2cells( filename, name, section, fields, range)
% Function to read HDF vdata and convert it to a cell
noOfFields = length(fields);
vstru = struct();
for i=1:noOfFields
    fname = fields{i};
%     fprintf('%s\t%s\t%s\n', filename, section, fname);
    fdata =  hdfread(filename, section, 'Fields', fname);
    fdata = fdata{1,1}(range);
    eval(sprintf('vstru.%s = fdata;', fname));
end
vlist{1} = {name, vstru};
end



