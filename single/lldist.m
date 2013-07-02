function [ d ] = lldist( lats1, lons1, lats2, lons2)
    diff_lats = abs(lats2 - lats1);
    diff_lons = abs(lons2 - lons1);
    diff_lons = abs((diff_lons > 180) * 360 - diff_lons);
    d = sqrt(diff_lats .^ 2 + diff_lons .^ 2);
%     d = distance(lats1, lons1, lats2, lons2);
end

% TRUE COMPUTATION OF DISTANCE
% % Compute the distance
% R = 6371; %km
% oneRad = pi/180;
% % Always calculate the shorter arc.
% diff_lons = (lons2 - lons1) .* oneRad;
% diff_lats = (lats2 - lats1) .* oneRad;
% lats1 = lats1 .* oneRad;
% lats2 = lats2 .* oneRad;
% 
% a = sin(diff_lats./2).^2 + cos(lats1) .* cos(lats2) .* sin(diff_lons./2).^2;
% if min(a) < 0
%     pause;
% end
% c = 2*atan2(sqrt(a), sqrt(1-a));
% d = R*c;