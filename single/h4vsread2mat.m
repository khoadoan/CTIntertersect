function [ output ] = h4vsread2mat( filename, section, field, range )
% Function to read HDF vdata and convert it to matrix
%     fprintf('%s\t%s - %s\n', filename, section, field);
    output = hdfread(filename, sprintf('%s%s', section, field), 'Fields', field);
    output = cell2mat(output);    
    if nargin == 4
        output = output(range);
    end
end

