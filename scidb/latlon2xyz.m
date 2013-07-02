function [ xyz ] = latlon2xyz( latitude, longitude, scale )
    latitude = latitude * (pi/180);
    longitude = longitude * (pi/180);
    xyz = [-cos(latitude) .* cos(longitude), sin(latitude), cos(latitude) .* sin(longitude)];
    xyz = scale * xyz / norm(xyz);
end

