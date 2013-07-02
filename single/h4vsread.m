function [ output ] = h4vsread( filename, field, subfield)
    % Function to read HDF vdata and convert it to matrix
    output = hdfread(filename, field, 'Fields', subfield);
end

