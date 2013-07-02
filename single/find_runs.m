function [ i ] = find_runs( x )
    l = length(x);
    i = find(x(1:l-1) - x(2:l));
    
    if x(1) == 1
        i = [1 i];
    end
    if x(l) == 1
        i = [i l];
    end
end

