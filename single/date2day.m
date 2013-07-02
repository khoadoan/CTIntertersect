function [ daysOfYear ] = date2day( yyyy, mm, dd )
% Convert date to the dayOfYear
days = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
if mod(yyyy, 4) == 0
    days(2) = 29;
end

daysOfYear = 0;
for m = 1:(mm-1)
    daysOfYear = daysOfYear + days(m);
end
daysOfYear = daysOfYear + dd;
end

