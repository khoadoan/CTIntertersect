hdffunction [ X ] = flatten( latitude, longitude, time, data )
% Flatten the SWATH reading into another dimension in the matrix

[m, n] = size(latitude);
X = zeros(m*n, 4);
    for i=1:m
        for j=1:n
            X(m*(i-1)+j, :) = [latitude(i, j), longitude(i, j), time(i), data(i, j)];
        end
    end
end

