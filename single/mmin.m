function [ m, r, c ] = mmin( X )
    [IR, CC] = min(X, [], 2);
    [m, r] = min(IR);
    c = CC(r);
end

