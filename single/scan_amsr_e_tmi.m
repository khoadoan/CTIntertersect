function [ intersection ] = scan_amsr_e_tmi( intersection, sat_index_interval, TMI_SWATH_WIDTH)
    prev_min_dist = 9999;
    for aIndex = 1:sat_index_interval
        [min_dist, min_index] = min(lldist(intersection.tmi.latitude(tmi_index_interval, [1, TMI_SWATH_WIDTH]), intersection.tmi.longitude(tmi_index_interval, [1, TMI_SWATH_WIDTH]), ...
                                   intersection.amsr_e.latitude(amsr_e_closest_index-aIndex, 1), intersection.amsr_e.longitude(amsr_e_closest_index-aIndex, 1)));
        if min(min_dist) <= prev_min_dist
             prev_min_index = min_index;
             prev_min_dist = min(min_dist);
        else
            if prev_min_dist(1) < prev_min_dist(2)
                 intersection.amsr_e_tmi{1} = [amsr_e_closest_index-aIndex, tmi_index_interval(prev_min_index(1)), 1];
            else
                 intersection.amsr_e_tmi{1} = [amsr_e_closest_index-aIndex, tmi_index_interval(prev_min_index(2)), TMI_SWATH_WIDTH];
            end
        end
    end
end

