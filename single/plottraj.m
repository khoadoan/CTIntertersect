 figure(1), hold on;
 c = 8; 
 t = 8;
 
 % plot trmm
 plot(trmm_orbits(t).longitude(:,208,1),trmm_orbits(t).latitude(:,208,1),'b*')
 plot(trmm_orbits(t).longitude(:,1,1),trmm_orbits(t).latitude(:,1,1),'b*')
 for i = 1:12,
     if abs(trmm_orbits(t).mbr(i,4)-trmm_orbits(t).mbr(i,3))<60,
        rectangle('position',[trmm_orbits(t).mbr(i,3), trmm_orbits(t).mbr(i,1), ...
     abs(trmm_orbits(t).mbr(i,4)-trmm_orbits(t).mbr(i,3)), abs(trmm_orbits(t).mbr(i,2)-trmm_orbits(t).mbr(i,1))])
     end
 end
 t = 9; 
 plot(trmm_orbits(t).longitude(:,208,1),trmm_orbits(t).latitude(:,208,1),'y*')
 plot(trmm_orbits(t).longitude(:,1,1),trmm_orbits(t).latitude(:,1,1),'y*')
 for i = 1:12,
     if abs(trmm_orbits(t).mbr(i,4)-trmm_orbits(t).mbr(i,3))<60,
        rectangle('position',[trmm_orbits(t).mbr(i,3), trmm_orbits(t).mbr(i,1), ...
     abs(trmm_orbits(t).mbr(i,4)-trmm_orbits(t).mbr(i,3)), abs(trmm_orbits(t).mbr(i,2)-trmm_orbits(t).mbr(i,1))])
     end
 end
% plot cloudsat
plot(cloudsat_orbits(c).longitude,cloudsat_orbits(c).latitude,'g.')
for j = 1:3,
    plot(cloudsat_orbits(c).longitude(intersect_cs(c).subsequence_index(j,1):intersect_cs(c).subsequence_index(j,2)),...
        cloudsat_orbits(c).latitude(intersect_cs(c).subsequence_index(j,1):intersect_cs(c).subsequence_index(j,2)),'r.')
end

i = c;
for subnum = 1:3,
    subseqence_stime = cloudsat_orbits(i).time(intersect_cs(i).subsequence_index(subnum,1));
    subseqence_etime = cloudsat_orbits(i).time(intersect_cs(i).subsequence_index(subnum,2));
    fprintf('cloudsat orbits = %d. subsequence %d \n', c, subnum);
    fprintf('cloudsat intersection start time = %d \n',  subseqence_stime);
    fprintf('cloudsat intersection end time = %d \n',  subseqence_etime);
    
    for cnt = 1:num_match,
        index = find(sum(intersect_cs(i).trmm_intersect_mbr(subnum).flag(:,:,cnt),2));
        if numel(index)~=0,
            trmm_mbr_time = zeros(length(index),2);
            for tindex = 1:length(index),
                trmm_mbr_time(tindex,1) = trmm_orbits(intersect_cs(i).matching(subnum,1)).time((index(tindex)-1)*250+1);
                trmm_mbr_time(tindex,2) = trmm_orbits(intersect_cs(i).matching(subnum,1)).time(index(tindex)*250);
                fprintf('trmm orbits = %d. trmm mbr number %d \n', intersect_cs(i).matching(subnum,1), index(tindex));
                fprintf('trmm mbr intersection start time = %d \n',   trmm_mbr_time(tindex,1));
                fprintf('trmm mbr intersection end time = %d \n',  trmm_mbr_time(tindex,2));
            end
        end
    end
    fprintf('############# \n');
end