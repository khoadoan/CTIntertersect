function [ str ] = time2str( hh, mm, ss )
% Give the format hhmmss of time
   str = sprintf('%02d%02d%02d', hh, mm, ss);
end

