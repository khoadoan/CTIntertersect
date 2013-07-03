function [ actual_year, actual_doy, actual_time] = get_time( year, doy, time)
% Given the year, the day of year, and the vector of seconds since the
% start of the day, return a vector of actual day, and year.
    % Deterime if this span to the next day
    SECONDS_IN_DAY = 24 * 60 * 60;
    actual_doy = doy + int64(time >= SECONDS_IN_DAY);
    actual_time = mod(time, SECONDS_IN_DAY);
    if mod(year, 4) == 0
        actual_year = year + int64(actual_doy > 366);
        actual_doy = mod(actual_doy-1, 366) + 1;
    else
        actual_year = year + int64(actual_doy > 365);
        actual_doy = mod(actual_doy-1, 365) + 1;
    end

end

