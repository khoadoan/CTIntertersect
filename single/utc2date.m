function [ dayInYear ] = utc2date( utc )
    SecondsIn4YearPeriod = 60*60*24*2*(365+366);
    SecondsIn1Day = 60*60*24;
    r = mod(utc, SecondsIn4YearPeriod);
    days = floor(r ./ SecondsIn1Day)
    
    dayInYear = days * logical(days <= 365) +...
                (days - 365) * logical(365 < days & days <= 730) +...
                (days - 730) * logical(730 < days & days <= 1096) +...
                (days - 1096) * logical(1096 < days);
end

