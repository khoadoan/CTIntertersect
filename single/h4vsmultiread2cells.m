function [ output ] = h4vsmultiread2cells( filename, section, fields, range)
    % Function to read HDF vdata and convert it to matrix
    noOfFields = length(fields);
    output = cell(1, noOfFields);
    for i=1:noOfFields
        fname = fields{i};
    %     fprintf('%s\t%s%s\n', filename, section, fname);
        fdata = hdfread(filename, sprintf('%s%s', section, fname), 'Fields', fname);
        fdata = cell2mat(fdata);
        output{i} = {fname, struct(fname, fdata(range))};
    end
end



