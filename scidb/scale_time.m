function [ milli ] = scale_time( t )
% Scale time from seconds to milliseconds
    milli = int64(t * 1000);
end

