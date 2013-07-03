function [ latOrLon ] = scale_latlon( ll )
% Convenient Function for Scaling the Latitude or Longitude to Integer
% Values
    latOrLon = int64(ll * 10000);
end

