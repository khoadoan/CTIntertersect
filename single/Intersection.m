% This code computes the TRMM-CloudSat Spatiotemporal Intersection.
% Main Output/Printout: CloudSat File Number A, CloudSat Subtrajectory/mbb Number B, TRMM File Number C, TRMM mbb D.
% Interpretation: The CoudSat Subtrajectory B in CloudSat File A intersects TRMM mbb D in TRMM File C.
% Author: Shen-Shyang Ho
% Date: 16 Dec. 2011.
% To Do:
% 1) The first cloudsat file (CloudSat File Number 1) that crosses two days is ignored. This needs to be included
% 2) Test and check the correctness of the code. Only 9 likely spatiotemporal intersection is identified (out of a possible 26 (?) for our test). 
% 3) Only identified the TRMM mbb and CloudSat subtrajectory that intersects. Need to find the closest point/region that intersects. 

code = 'C:\school\matlab\'; % change to your directory. 
dayOfYear = 305; % 2010

%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing CloudSat
%%%%%%%%%%%%%%%%%%%%%%%%
cloudsat_directory = 'C:\school\data\cloudsat-2008-day-305\hdf\'; % change to your directory.
cd(cloudsat_directory);
filenames_cs = dir;
filenames_cs = filenames_cs(3:numel(filenames_cs));
num_cs_file = numel(filenames_cs);
cd(code);

tic;
cloudsat_orbits = struct('filename',{}, 'start_day',{}, 'end_day', {}, 'start_time',{}, 'end_time', {}, 'time',{}, 'latitude',{},'longitude',{}); 
for num_cs = 1: num_cs_file,
    file_cs = sprintf('%s%s', cloudsat_directory, filenames_cs(num_cs).name);
    disp(file_cs);
    UTC_start = hdfread(file_cs,'/2B-GEOPROF/Geolocation Fields/UTC_start', 'Fields', 'UTC_start', 'FirstRecord',1 ,'NumRecords',1);
    Profile_time = hdfread(file_cs,'/2B-GEOPROF/Geolocation Fields/Profile_time', 'Fields', 'Profile_time', 'FirstRecord',1 ,'NumRecords',37081);
    Latitude_cs = hdfread(file_cs,'/2B-GEOPROF/Geolocation Fields/Latitude', 'Fields', 'Latitude', 'FirstRecord',1 ,'NumRecords',37081);
    Longitude_cs = hdfread(file_cs,'/2B-GEOPROF/Geolocation Fields/Longitude', 'Fields', 'Longitude', 'FirstRecord',1 ,'NumRecords',37081);
    % update data structure
    cloudsat_orbits(num_cs).filename = filenames_cs(num_cs).name;
    cloudsat_orbits(num_cs).time = double(cell2mat(UTC_start) + cell2mat(Profile_time))/3600;
    cloudsat_orbits(num_cs).latitude = cell2mat(Latitude_cs);
    cloudsat_orbits(num_cs).longitude = cell2mat(Longitude_cs);
    cloudsat_orbits(num_cs).start_day = int16(str2double(filenames_cs(num_cs).name(5:7)));
    if cloudsat_orbits(num_cs).time(37081) > 24, 
        cloudsat_orbits(num_cs).end_day = cloudsat_orbits(num_cs).start_day + 1;
    else 
        cloudsat_orbits(num_cs).end_day = cloudsat_orbits(num_cs).start_day;
    end
    cloudsat_orbits(num_cs).start_time = cloudsat_orbits(num_cs).time(1);
    cloudsat_orbits(num_cs).end_time = cloudsat_orbits(num_cs).time(37081);
end;
toc
%%%%%%%%%%%%%%%%%%%%%%%%
% Preprocessing TRMM
%%%%%%%%%%%%%%%%%%%%%%%%
trmm_directory = 'C:\school\data\TRMM2A12-2008-day-305\hdf\'; % change to your directory.
cd(trmm_directory);
filenames_trmm = dir;
filenames_trmm = filenames_trmm(3:numel(filenames_trmm));
num_trmm_file = numel(filenames_trmm);
cd(code);
trmm_orbits = struct('filename',{}, 'time',{}, 'start_time',{}, 'end_time',{}, 'latitude',{},'longitude',{},'mbr',{}); 

tic;
for num_trmm = 1: num_trmm_file,
    file_trmm = sprintf('%s%s', trmm_directory, filenames_trmm(num_trmm).name);
    disp(file_trmm);
    geolocation = hdfread(file_trmm, '/DATA_GRANULE/SwathData/geolocation', 'Index', {[1  1  1],[1  1  1],[3019   208     2]});
    Latitude_trmm = geolocation(:,:,1);
    Longitude_trmm = geolocation(:,:,2); 
    scan_hour = hdfread(file_trmm, '/DATA_GRANULE/SwathData/scan_time', 'Fields', 'hour', 'FirstRecord',1 ,'NumRecords',3019);
    scan_min = hdfread(file_trmm, '/DATA_GRANULE/SwathData/scan_time', 'Fields', 'minute', 'FirstRecord',1 ,'NumRecords',3019);
    scan_sec = hdfread(file_trmm, '/DATA_GRANULE/SwathData/scan_time', 'Fields', 'second', 'FirstRecord',1 ,'NumRecords',3019);
    scan_dayOfYear = hdfread(file_trmm, '/DATA_GRANULE/SwathData/scan_time', 'Fields', 'dayOfYear', 'FirstRecord',1 ,'NumRecords',3019);
    scan_hour = cell2mat(scan_hour);
    scan_min = cell2mat(scan_min);
    scan_sec = cell2mat(scan_sec);
    scan_dayOfYear = cell2mat(scan_dayOfYear);
    trmm_time = (double(scan_hour) + double(scan_min)/60 + double(scan_sec)/3600);
    
    % update data structure
    trmm_orbits(num_trmm).filename = filenames_trmm(num_trmm).name;
    trmm_orbits(num_trmm).time = trmm_time;
    trmm_orbits(num_trmm).latitude = Latitude_trmm;
    trmm_orbits(num_trmm).longitude = Longitude_trmm;
    trmm_orbits(num_trmm).start_time = trmm_orbits(num_trmm).time(1);
    trmm_orbits(num_trmm).end_time = trmm_orbits(num_trmm).time(3019);
    for i = 1:12,
        ptA = [Latitude_trmm((i-1)*250+1,1) Longitude_trmm((i-1)*250+1,1)];
        ptB = [Latitude_trmm((i-1)*250+1,208) Longitude_trmm((i-1)*250+1,208)];
        ptC = [Latitude_trmm(i*250,1) Longitude_trmm(i*250,1)];
        ptD = [Latitude_trmm(i*250,208) Longitude_trmm(i*250,208)];
        pts = [ptA; ptB; ptC; ptD];
        min_lat = min(pts(:,1));
        max_lat = max(pts(:,1));
        min_lon = min(pts(:,2));
        max_lon = max(pts(:,2));
        trmm_orbits(num_trmm).mbr(i,:) = [min_lat max_lat min_lon max_lon]; 
    end
end;
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subseting cloudsat data based on TRMM domain knowledge into subsequences
% and minimum bounding box (mbb)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
intersect_cs = struct('subsequence_index',{},'mbr',{},'trmm_intersect_mbr',{},'matching',{},'final_trmm_intersect_mbr',{});
% subsequence_index: number of rows = number of subtrajectories
%                    first column = start index of subtrajectory
%                    second column = end index of subtrajectory
% mbr (minimum bounding box): number of rows = number of subtrajectories
%                    first column = minimum latitude of bounding box
%                    second column = maximum latitide
%                    third column = minimum longitude
%                    fourth column = maximum longitude
% trmm_intersect_mbr : The number of trmm_intersect_mbr = the number of subtrajectories
%                      flag data structure: [12 x 4 x n] correspond to 12
%                      TRMM mbb and 4 corners of cloudsat mbb. n is the
%                      number of TRMM files that the subtrajectory intersects.
%                      first column is the bottom-right
%                      second column is the bottom-left
%                      third column is the top-right
%                      fourth column is the top-left
%                      if entry is 0, the Cloudsat mbb corner is not in TRMM mbb
%                      if entry is 1, the Cloudsat mbb corner is in the
%                      TRMM mbb.
% matching:  number of rows = number of subtrajectories
%           if entry is not 0, it is the TRMM file (index) that intersects the subtrajectory ROW_NUMBER
% final_trmm_intersect_mbr: CloudSat File Number A, CloudSat Subtrajectory/mbb Number B, TRMM File Number C, TRMM mbb D.
%                           Interpretation: The CoudSat Subtrajectory B in CloudSat File A intersects TRMM mbb D in TRMM File C.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic;
for i = 1:num_cs_file,
    % characteristic of trmm: latitude between -40 and + 40
    index = logical(cloudsat_orbits(i).latitude < 40) & logical(cloudsat_orbits(i).latitude > -40);
    
    changepoints = find(index(1,1:37080) - index(1,2:37081));
    cstime_index = find(index); % csindex when index = 1;
    if index(1) == 1, % start index satisfy above condition
        if sum(cstime_index == changepoints(1)), % The first subsequence satisfies the above condition,
            length_changepoint_list = length(changepoints);
            even = floor(length_changepoint_list/2);
            changepoints(2*(1:even)) = changepoints(2*(1:even))+1;
            if mod(length_changepoint_list,2)==0,
                subsequence_index = [1 changepoints 37081];
            else
                subsequence_index = [1 changepoints(1:length_changepoint_list-1)];
            end;
        else
            disp('check for error!!');
        end
    elseif index(1) == 0, % start index does not satisfy above condition
        length_changepoint_list = length(changepoints);
        even = floor(length_changepoint_list/2);
        changepoints(2*(1:even)-1) = changepoints(2*(1:even)-1)+1;
        if mod(length_changepoint_list,2)==1,
            subsequence_index = [changepoints 37081];
        else
            subsequence_index = [changepoints(1:length_changepoint_list-1)];
        end;
    end
    
    % start and end index for cloudsat data subsequences between trmm latitude bewteen -40 and +40
    number_subsequence = numel(subsequence_index)/2;
    subsequence_index = reshape(subsequence_index', 2, number_subsequence)';
    % subset of time period in cloudsat satisfying the above trmm characteristics.
    % cstime_subset = cloudsat_orbits(num_cs_file).time(index);
    matching = zeros(number_subsequence,3);
    mbr = zeros(number_subsequence,4); % [min lat, max lat, min lon, max lon] 
    for subnum = 1:number_subsequence,  
        count = 1;
        for j = 1:num_trmm_file,
            if (cloudsat_orbits(i).start_day == cloudsat_orbits(i).end_day)
                % start/end time comparison of trmm file and cloudsat subsequences 
                if ((cloudsat_orbits(i).time(subsequence_index(subnum,1)) < trmm_orbits(j).start_time ...
                        && cloudsat_orbits(i).time(subsequence_index(subnum,2)) > trmm_orbits(j).start_time)...
                        || (cloudsat_orbits(i).time(subsequence_index(subnum,1)) > trmm_orbits(j).start_time && ...
                        cloudsat_orbits(i).time(subsequence_index(subnum,2)) < trmm_orbits(j).end_time)...
                        || (cloudsat_orbits(i).time(subsequence_index(subnum,1)) < trmm_orbits(j).end_time && ...
                        cloudsat_orbits(i).time(subsequence_index(subnum,2)) > trmm_orbits(j).end_time))
                    matching(subnum,count) = j;
                    count = count + 1;
                    % update CloudSat MBR
                    mbr(subnum,1) = min(cloudsat_orbits(i).latitude(subsequence_index(subnum,1)),...
                    cloudsat_orbits(i).latitude(subsequence_index(subnum,2)));
                    mbr(subnum,2) = max(cloudsat_orbits(i).latitude(subsequence_index(subnum,1)),...
                    cloudsat_orbits(i).latitude(subsequence_index(subnum,2)));
                    mbr(subnum,3) = min(cloudsat_orbits(i).longitude(subsequence_index(subnum,1)),...
                    cloudsat_orbits(i).longitude(subsequence_index(subnum,2)));
                    mbr(subnum,4) = max(cloudsat_orbits(i).longitude(subsequence_index(subnum,1)),...
                    cloudsat_orbits(i).longitude(subsequence_index(subnum,2)));
                end
            end
        end
    end
    intersect_cs(i).subsequence_index = subsequence_index;
    intersect_cs(i).mbr = mbr;
    intersect_cs(i).matching = matching;
end
toc
tic;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Spatial and Temporal Matching of TRMM mbb and CloudSat subtrajectories
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:num_cs_file
    mbr_number = [];
    for subnum = 1:size(intersect_cs(i).subsequence_index,1),
        % SPATIAL: compare TRMM MBR for matching(subnum) with CloudSat MBR
        num_match = sum(intersect_cs(i).matching(subnum,:)~=0);
        flag = zeros(12,4,num_match);
        for cnt = 1:num_match,
           ind = intersect_cs(i).matching(subnum, cnt); 
           for num_mbr = 1:12,
               if sign(trmm_orbits(ind).mbr(num_mbr,3))~=sign(trmm_orbits(ind).mbr(num_mbr,4)),
                    % cross -180/180 longitude
                    % cloudsat bottom-right (min lat, max lon)
                   %disp('here')
                   if (mbr(subnum,1)>trmm_orbits(ind).mbr(num_mbr,1) && mbr(subnum,1)<trmm_orbits(ind).mbr(num_mbr,2)) && ...
                       ((mbr(subnum,4)<trmm_orbits(ind).mbr(num_mbr,3) && mbr(subnum,4)>-180) || ...
                       (mbr(subnum,4)<180 && mbr(subnum,4)>trmm_orbits(ind).mbr(num_mbr,4)))    
                        flag(num_mbr,1,cnt) = 1;
                   end
                   % cloudsat bottom-left (min lat, min lon)
                   if (mbr(subnum,1)>trmm_orbits(ind).mbr(num_mbr,1) && mbr(subnum,1)<trmm_orbits(ind).mbr(num_mbr,2)) && ...
                       ((mbr(subnum,3)<trmm_orbits(ind).mbr(num_mbr,3) && mbr(subnum,3)>-180) || ...
                       (mbr(subnum,3)<180 && mbr(subnum,3)>trmm_orbits(ind).mbr(num_mbr,4)))   
                        flag(num_mbr,2,cnt) = 1;
                   end
                    % cloudsat top-right (max lat, max lon)
                   if (mbr(subnum,2)>trmm_orbits(ind).mbr(num_mbr,1) && mbr(subnum,2)<trmm_orbits(ind).mbr(num_mbr,2)) && ...
                       ((mbr(subnum,4)<trmm_orbits(ind).mbr(num_mbr,3) && mbr(subnum,4)>-180) || ...
                       (mbr(subnum,4)<180 && mbr(subnum,4)>trmm_orbits(ind).mbr(num_mbr,4)))  
                        flag(num_mbr,3,cnt) = 1;
                   end
                   % cloudsat top-left (max lat, min lon)
                   if (mbr(subnum,2)>trmm_orbits(ind).mbr(num_mbr,1) && mbr(subnum,2)<trmm_orbits(ind).mbr(num_mbr,2)) && ...
                      ((mbr(subnum,3)<trmm_orbits(ind).mbr(num_mbr,3) && mbr(subnum,3)>-180) || ...
                       (mbr(subnum,3)<180 && mbr(subnum,3)>trmm_orbits(ind).mbr(num_mbr,4)))  
                        flag(num_mbr,4,cnt) = 1;
                   end
               else
                   % cloudsat bottom-right (min lat, max lon)
                   if (mbr(subnum,1)>trmm_orbits(ind).mbr(num_mbr,1) && mbr(subnum,1)<trmm_orbits(ind).mbr(num_mbr,2)) && ...
                       (mbr(subnum,4)>trmm_orbits(ind).mbr(num_mbr,3) && mbr(subnum,4)<trmm_orbits(ind).mbr(num_mbr,4))    
                        flag(num_mbr,1,cnt) = 1;
                   end
                   % cloudsat bottom-left (min lat, min lon)
                   if (mbr(subnum,1)>trmm_orbits(ind).mbr(num_mbr,1) && mbr(subnum,1)<trmm_orbits(ind).mbr(num_mbr,2)) && ...
                       (mbr(subnum,3)>trmm_orbits(ind).mbr(num_mbr,3) && mbr(subnum,3)<trmm_orbits(ind).mbr(num_mbr,4))    
                        flag(num_mbr,2,cnt) = 1;
                   end
                    % cloudsat top-right (max lat, max lon)
                   if (mbr(subnum,2)>trmm_orbits(ind).mbr(num_mbr,1) && mbr(subnum,2)<trmm_orbits(ind).mbr(num_mbr,2)) && ...
                       (mbr(subnum,4)>trmm_orbits(ind).mbr(num_mbr,3) && mbr(subnum,4)<trmm_orbits(ind).mbr(num_mbr,4))    
                        flag(num_mbr,3,cnt) = 1;
                   end
                   % cloudsat top-left (max lat, min lon)
                   if (mbr(subnum,2)>trmm_orbits(ind).mbr(num_mbr,1) && mbr(subnum,2)<trmm_orbits(ind).mbr(num_mbr,2)) && ...
                       (mbr(subnum,3)>trmm_orbits(ind).mbr(num_mbr,3) && mbr(subnum,3)<trmm_orbits(ind).mbr(num_mbr,4))    
                        flag(num_mbr,4,cnt) = 1;
                   end    
               end
           end
        end
        intersect_cs(i).trmm_intersect_mbr(subnum).flag = flag;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % TEMPORAL: compare TRMM MBR for matching(subnum) with CloudSat MBR
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        subseq_stime = cloudsat_orbits(i).time(intersect_cs(i).subsequence_index(subnum,1));
        subseq_etime = cloudsat_orbits(i).time(intersect_cs(i).subsequence_index(subnum,2));
        for cnt = 1:num_match,
            index = find(sum(intersect_cs(i).trmm_intersect_mbr(subnum).flag(:,:,cnt),2));
            if numel(index)~=0,
                trmm_mbr_time = zeros(length(index),2);
                for tindex = 1:length(index),
                    trmm_mbr_time(tindex,1) = trmm_orbits(intersect_cs(i).matching(subnum,1)).time((index(tindex)-1)*250+1);
                    trmm_mbr_time(tindex,2) = trmm_orbits(intersect_cs(i).matching(subnum,1)).time(index(tindex)*250);
                    if (subseq_stime > trmm_mbr_time(tindex,1) && subseq_stime < trmm_mbr_time(tindex,2)) || ...
                       (subseq_stime < trmm_mbr_time(tindex,1) && subseq_etime > trmm_mbr_time(tindex,2)) ||...
                       (subseq_etime > trmm_mbr_time(tindex,1) && subseq_etime < trmm_mbr_time(tindex,2))
                       mbr_number = [mbr_number; i subnum intersect_cs(i).matching(subnum,1) index(tindex)];
                    end
                end
                intersect_cs(i).final_trmm_intersect_mbr = mbr_number;
            end     
        end       
    end       
end 
toc
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Display output: FORMAT: CloudSat File Number A, CloudSat Subtrajectory/mbb Number B, TRMM File Number C, TRMM mbb D.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:num_cs_file,
   disp(int8(intersect_cs(i).final_trmm_intersect_mbr)); 
end
