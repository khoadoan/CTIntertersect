
plot(intersection.amsr_e.longitude(amsr_e_index_interval, [1 AMSR_E_SWATH_WIDTH]),...
     intersection.amsr_e.latitude(amsr_e_index_interval, [1 AMSR_E_SWATH_WIDTH]));
hold on;
plot(intersection.tmi.longitude(tmi_index_interval, [1 TMI_SWATH_WIDTH]),...
     intersection.tmi.latitude(tmi_index_interval, [1 TMI_SWATH_WIDTH]), '-.');

plot(intersection.amsr_e.longitude(amsr_e_closest_index, :),...
     intersection.amsr_e.latitude(amsr_e_closest_index, :), 'y');
 
plot(intersection.tmi.longitude(tmi_closest_index, :),...
     intersection.tmi.latitude(tmi_closest_index, :), '-.', 'color', 'y');

plot(intersection.amsr_e.longitude(intersection.amsr_e_tmi{1}(1), :),...
     intersection.amsr_e.latitude(intersection.amsr_e_tmi{1}(1), :));
plot(intersection.amsr_e.longitude(intersection.amsr_e_tmi{2}(1), :),...
     intersection.amsr_e.latitude(intersection.amsr_e_tmi{2}(1), :));
plot(intersection.amsr_e.longitude(intersection.amsr_e_tmi{3}(1), :),...
     intersection.amsr_e.latitude(intersection.amsr_e_tmi{3}(1), :));
plot(intersection.amsr_e.longitude(intersection.amsr_e_tmi{4}(1), :),...
     intersection.amsr_e.latitude(intersection.amsr_e_tmi{4}(1), :));
plot(intersection.tmi.longitude(intersection.amsr_e_tmi{1}(3), :),...
     intersection.tmi.latitude(intersection.amsr_e_tmi{1}(3), :), '-.');
plot(intersection.tmi.longitude(intersection.amsr_e_tmi{2}(3), :),...
     intersection.tmi.latitude(intersection.amsr_e_tmi{2}(3), :), '-.');
plot(intersection.tmi.longitude(intersection.amsr_e_tmi{3}(3), :),...
     intersection.tmi.latitude(intersection.amsr_e_tmi{3}(3), :), '-.');
plot(intersection.tmi.longitude(intersection.amsr_e_tmi{4}(3), :),...
     intersection.tmi.latitude(intersection.amsr_e_tmi{4}(3), :), '-.');
 