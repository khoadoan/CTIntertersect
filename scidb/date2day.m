function [ dayOfYear ] = date2day( y, m, d )
% Given a date (year, month, day) - or vectors of dates, return the day of the year
% Example: 02/10/2007   ->  41
    y = double(y);
    m = double(m);
    d = double(d);
    dn = datenum(y, m, d);
    dn0 = datenum(y, 1, 1);
    dayOfYear = int64(dn - dn0 + 1);
end

