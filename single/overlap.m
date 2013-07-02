function [ indexes ] = overlap( time1, time2, delta)
    % find overlaping of vector time1 and vector time2
    % assuming size(time1) >> size(time2)
    % return the range of indexes in time1 vector
    left = find(logical(time1 >= time2(1) - delta), 1, 'first');
    right = find(logical(time1 <= time2(length(time2)) + delta), 1, 'last');
    indexes = left:right;
end

