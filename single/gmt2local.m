function [ local ] = gmt2local( gmt, lon )
% Compute local time at the specified longitude
% GMT and Local Time are in hours from the start of the day
hoursIn1Degree = 24 / 360;
local = gmt + lon * hoursIn1Degree;
end

