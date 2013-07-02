function [ pairs ] = find_pairing( cs_start_index, cs_end_index, trmm_start_index, trmm_step, trmm_latitude, trmm_longitude, cs_latitude, cs_longitude )
    pairs = zeros(cs_end_index - cs_start_index + 1, 3);
    i = 0;
    for cs_index = cs_start_index:cs_end_index
        i = i + 1;
        lldist(trmm_latitude(trmm_start_index) 
    end
end

