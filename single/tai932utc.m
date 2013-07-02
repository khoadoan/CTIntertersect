function [ utc ] = tai932utc( tai93 )
% Currently TAI is 33 seconds ahead of UTC
seconds_difference = -33;
seconds_in_1day = 60*60*24;
% Convert TAI93 time to UTC of Today
utc = mod(tai93, seconds_in_1day) + seconds_difference;
end

