function [ output_args ] = write_intersect_output_v6( intersections, output_dir )
    %trmm_1C21_dir = 'C:\school\data\trmm-2010-day-60\1C21\';
    %trmm_2A25_dir = 'C:\school\data\trmm-2010-day-60\2A25\';
    %trmm_2A23_dir = 'C:\school\data\trmm-2010-day-60\2A23\';
    % TODO: This section will be either moved to the
    % scanning above or implemented as a function
    % Find the pairing for TRMM and CS in this intersection curtain
    noOfIntersections = length(intersections);
    
    for iIndex = 1:noOfIntersections
        % Prepare info for this intersection
        cs_file = intersections(iIndex).cs_filename;
        trmm_1C21_file = intersections(iIndex).trmm_filename;
        curtain_indexes = intersections(iIndex).curtain_indexes;
        CPR_ICenter_Index = curtain_indexes(1,1);
        PR_ICenter_Index = curtain_indexes(1,2);
        pairs = curtain_indexes(2:size(curtain_indexes,1), :);
        cs_curtain_length = size(pairs, 1);
        
        % Info from CS Filename -
        % 2008304224420_13348_CS_2B-GEOPROF_GRANULE_P_R04_E02.hdf
        cs_filename_extract_pattern = '(\d\d\d\d)(\d\d\d)(\d\d)(\d\d)(\d\d)_(\d\d\d\d\d)';
        cs_filename_extract_tokens = regexp(cs_file, cs_filename_extract_pattern, 'tokens');
        cs_filename_extract_tokens = cs_filename_extract_tokens{1,1};

        % Info from TRMM Filename - 1B21.20100301.70015.7.hdf
        trmm_1C21_filename_extract_pattern = '1C21\.(\d\d)(\d\d)(\d\d)\.(\d\d\d\d\d)';
        trmm_1C21_filename_extract_tokens = regexp(trmm_1C21_file, trmm_1C21_filename_extract_pattern, 'tokens');
        trmm_1C21_filename_extract_tokens = trmm_1C21_filename_extract_tokens{1,1};
        
        % Locations to Other TRMM Files for Contents
        trmm_2A23_file = regexprep(trmm_1C21_file, '1C21', '2A23');
        trmm_2A25_file = regexprep(trmm_1C21_file, '1C21', '2A25');
        
        %% FILENAME Construction
        % Extraction of Basic Components
        % CPR Data
        CPR_Time = h4vsread2mat(cs_file, '/2B-GEOPROF/Geolocation Fields/', 'Profile_time');
        CPR_UTC_Start = h4vsread2mat(cs_file, '/2B-GEOPROF/Geolocation Fields/', 'UTC_start');
        CPR_Latitude = h4vsread2mat(cs_file, '/2B-GEOPROF/Geolocation Fields/', 'Latitude');
        CPR_Longitude = h4vsread2mat(cs_file, '/2B-GEOPROF/Geolocation Fields/', 'Longitude');
        
        CPR_Reflectivity = hdfread(cs_file, '/2B-GEOPROF/Data Fields/Radar_Reflectivity');
        CPR_Cloud_mask = hdfread(cs_file, '/2B-GEOPROF/Data Fields/CPR_Cloud_mask');
        CPR_MODIS_Cloud_Fraction = h4vsread2mat(cs_file, '/2B-GEOPROF/Data Fields/', 'MODIS_Cloud_Fraction');
        cs_scan_length = length(CPR_Time);
        
        % PR Data
        PR_geolocation = hdfread(trmm_1C21_file, '/DATA_GRANULE/SwathData/geolocation');
        PR_Latitude = PR_geolocation(:, :, 1);
        PR_Longitude = PR_geolocation(:, :, 2);
        
        % Convert PR Time to CPR Centric time
        PR_Time = trmm2csTime(trmm_1C21_file, str2num(cs_filename_extract_tokens{2}), CPR_UTC_Start); 
        PR_Reflectivity = hdfread(trmm_1C21_file, '/DATA_GRANULE/SwathData/normalSample');
        PR_Corrected_Z =  hdfread(trmm_2A25_file, '/DATA_GRANULE/SwathData/correctZFactor');
        PR_Rain_Rate = hdfread(trmm_2A25_file, 'DATA_GRANULE/SwathData/rain');
        PR_OS_Rain = hdfread(trmm_1C21_file, '/DATA_GRANULE/SwathData/osRain');
        trmm_scan_length = length(PR_Time);
        
        % Context Scans of CS and TRMM
        cs_curtain_range = pairs(1,1):pairs(cs_curtain_length,1);
        
        % IMPORTANT: ignore any intersections that span 2 files
        cs_curtain_start_index = pairs(1,1);
        cs_curtain_end_index = pairs(cs_curtain_length,1);
        trmm_curtain_start_index = min(pairs(1,2), pairs(cs_curtain_length,2));
        trmm_curtain_end_index = max(pairs(1,2), pairs(cs_curtain_length,2));
        if (cs_curtain_start_index-50) >= 1 && (cs_curtain_length+50 <= cs_scan_length) ...
                && (trmm_curtain_start_index-10 >=1) && (trmm_curtain_end_index+10) <= trmm_scan_length
            cs_scan_context_range = (cs_curtain_start_index-50):(cs_curtain_end_index+50);
            cs_scan_curtain_range = cs_curtain_start_index:cs_curtain_end_index;
            trmm_scan_block_range =  (trmm_curtain_start_index-10):(trmm_curtain_end_index+10);
            trmm_curtain_range = trmm_curtain_start_index:trmm_curtain_end_index;

            CPR_Curtain_Height = hdfread(cs_file, '/2B-GEOPROF/Geolocation Fields/Height');
            CPR_Curtain_Height = CPR_Curtain_Height(cs_curtain_range, :);
            CPR_Curtain_DEM_elevation = h4vsread2mat(cs_file, '/2B-GEOPROF/Geolocation Fields/', 'DEM_elevation', cs_curtain_range);
            CPR_Curtain_Reflectivity = CPR_Reflectivity(cs_scan_curtain_range, :); 
            reflectivity_reading_length = size(CPR_Curtain_Reflectivity, 2);
            CPR_Curtain_Valid_Reflectivity = ones(size(cs_scan_curtain_range), reflectivity_reading_length) * (-8888); %missing values
            
            CPR_Curtain_MODIS_Cloud_Fraction = CPR_MODIS_Cloud_Fraction(cs_scan_curtain_range);

            PR_Curtain_Latitude = zeros(1, cs_curtain_length);
            PR_Curtain_Longitude = zeros(1, cs_curtain_length);
            PR_Curtain_Time = zeros(1, cs_curtain_length);
            PR_Curtain_Reflectivity = zeros(cs_curtain_length, size(PR_Reflectivity, 3));
            PR_Curtain_Corrected_Z = zeros(cs_curtain_length, size(PR_Corrected_Z, 3));
            PR_Curtain_Rain_Rate = zeros(cs_curtain_length, size(PR_Rain_Rate, 3));
            PR_Curtain_Scan_Indices = zeros(1, cs_curtain_length);
            PR_Curtain_Ray_Indices = pairs(:, 3)';
            
            PR_2A23_rainType = hdfread(trmm_2A23_file, '/DATA_GRANULE/SwathData/rainType');
            PR_2A23_Curtain_rainType = zeros(1, cs_curtain_length);
            for i = 1:cs_curtain_length
                PR_Curtain_Scan_Indices(i) = pairs(i, 2) - trmm_curtain_start_index + 10;
                PR_Curtain_Latitude(i) = PR_Latitude(pairs(i, 2), pairs(i, 3));
                PR_Curtain_Longitude(i) = PR_Longitude(pairs(i, 2), pairs(i, 3));
                PR_Curtain_Time(i) = PR_Time(pairs(i,2));
                PR_Curtain_Reflectivity(i, :) = PR_Reflectivity(pairs(i, 2), pairs(i, 3), :);
                PR_Curtain_Rain_Rate(i, :) = PR_Rain_Rate(pairs(i, 2), pairs(i, 3), :);
                PR_Curtain_Corrected_Z(i, :) = PR_Corrected_Z(pairs(i, 2), pairs(i, 3), :);
                PR_2A23_Curtain_rainType(i) = PR_2A23_rainType(pairs(i, 2), pairs(i, 3));
                heigh_GR_DEM_index = find(logical(CPR_Curtain_Height(i, :) > CPR_Curtain_DEM_elevation(i)), 1, 'last') - 10; %5 higher than equal point
                CPR_Curtain_Valid_Reflectivity(i, 1:heigh_GR_DEM_index) = CPR_Curtain_Reflectivity(i, 1:heigh_GR_DEM_index);
            end

            % Time
            cs_center_time = CPR_Time(CPR_ICenter_Index) + CPR_UTC_Start;
            cs_center_second = mod(cs_center_time, 60);
            cs_center_minute = mod((cs_center_time - cs_center_second)/60, 60);
            cs_center_hour = ((cs_center_time - cs_center_second)/60 - cs_center_minute)/60;
            cs_center_time_str = time2str(cs_center_hour, cs_center_minute, round(cs_center_second));

            % Overpass Time
            dt_num = CPR_Time(CPR_ICenter_Index) - PR_Time(PR_ICenter_Index);
            filename_dt_num = round(dt_num/60);
            if filename_dt_num > 0 % PR First
                filename_dt = sprintf('%02d%s', filename_dt_num, 'T');
            else % CPR First
                filename_dt = sprintf('%02d%s', abs(filename_dt_num), 'C');
            end

            % CPR Lat and Lon at Center
            if CPR_Latitude(CPR_ICenter_Index) > 0
                LT = sprintf('%02d%s', round(CPR_Latitude(CPR_ICenter_Index)), 'N');
            else
                LT = sprintf('%03d%s', abs(round(CPR_Latitude(CPR_ICenter_Index))), 'S');
            end
            if CPR_Longitude(CPR_ICenter_Index) > 0
                LG = sprintf('%02d%s', round(CPR_Longitude(CPR_ICenter_Index)), 'E');
            else
                LG = sprintf('%03d%s', abs(round(CPR_Longitude(CPR_ICenter_Index))), 'W');
            end

            % ABCDE section
            % A 
            % UNSURE: using rainType of 2A23, rainType[i] = -88 -> no rain
            A = logical(PR_2A23_Curtain_rainType ~= -88); 
            A = sum(A) / length(A);
            A = ceil(A/5);
            if A <= 9
                A = num2str(A);
            else
                A = 'a';
            end
            
            % B
            B = double(max(max(PR_Curtain_Rain_Rate))) / 100
            B = ceil(B/5);
            if B <= 9
                B = num2str(B);
            else
                B = 'a';
            end
            
            % C
            C = double(max(max(CPR_Curtain_Valid_Reflectivity))) / 100 
            if C < -40
                C = '0';
            elseif C < -30
                C = '1';
            elseif C < -20
                C = '2';
            elseif C < -10
                C = '3';
            elseif C < 0
                C = '4';
            elseif C < 10
                C = '5';
            elseif C < 20
                C = '6';
            elseif C < 30
                C = '7';
            elseif C < 40    
                C = '8';
            else
                C = '9';
            end
            
            % D
            D = max(max(PR_Curtain_Corrected_Z));
            D = ceil(D / 8);
            if D > 9
                D = 'a';
            else
                D = num2str(D);
            end
            % E
            E = double(sum(logical(CPR_Curtain_MODIS_Cloud_Fraction > 0)) / length(CPR_Curtain_MODIS_Cloud_Fraction));
            E = ceil(E/0.1);
            if E <= 9
                E = num2str(E);
            else
                E = 'a';
            end
            
            % Final Filename    
            cs_trmm_1C21_filename = sprintf('%s%s%s_%s_%s_%s_%s%s%s%s%s_%s_CS_%s_TR.hdf', ...
                cs_filename_extract_tokens{1}, cs_filename_extract_tokens{2}, cs_center_time_str, filename_dt, LT, LG, A, B, C, D, E, ... 
                cs_filename_extract_tokens{6}, trmm_1C21_filename_extract_tokens{4});
            fprintf('%d. Filename = %s\n', iIndex ,cs_trmm_1C21_filename);
            
%             continue;
            
            %% Write Output
            %% WRITE SDS OUTPUT
            % Open file for SD
            cs_trmm_hdf_file = sprintf('%s%s', output_dir, cs_trmm_1C21_filename);
            cs_trmm_hdf_id = hdfsd('start', cs_trmm_hdf_file, 'DFACC_CREATE');

            CPR_Curtain_Latitude = CPR_Latitude(cs_scan_context_range);
            CPR_Curtain_Longitude = CPR_Longitude(cs_scan_context_range);
            CPR_Curtain_Time = CPR_Time(cs_scan_context_range);
            CPR_Curtain_Gaseous_Attenuation = hdfread(cs_file, '/2B-GEOPROF/Data Fields/Gaseous_Attenuation');
            CPR_Curtain_Gaseous_Attenuation = CPR_Curtain_Gaseous_Attenuation(cs_scan_context_range, :);

            PR_Block_Latitude = PR_Latitude(trmm_scan_block_range, :);
            PR_Block_Longitude = PR_Longitude(trmm_scan_block_range, :);
            PR_Block_Time = PR_Time(trmm_scan_block_range);

            [nray, nbin] = size(CPR_Curtain_Height);

            % PR 2A25 Content
            PR_Block_Rain_Rate = get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/rain', trmm_scan_block_range);
            PR_Block_Corrected_Z = get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/correctZFactor', trmm_scan_block_range);
            PR_Block_Reflectivity = get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/normalSample', trmm_scan_block_range);      

            write_sds(CPR_Curtain_Height, 'CPR Height', 'int16', cs_trmm_hdf_id);
            write_sds(CPR_Curtain_Latitude, 'CPR Latitude', 'float', cs_trmm_hdf_id);
            write_sds(CPR_Curtain_Longitude, 'CPR Longitude', 'float', cs_trmm_hdf_id);
            write_sds(CPR_Curtain_Time, 'CPR Time', 'float', cs_trmm_hdf_id);
            write_sds(CPR_Reflectivity(cs_scan_context_range, :), 'CPR Reflectivity (GEOPROF)', 'int16', cs_trmm_hdf_id);
            write_sds(CPR_Cloud_mask(cs_scan_context_range, :), 'CPR CPR_Cloud_mask (GEOPROF)', 'int8', cs_trmm_hdf_id);
            write_sds(CPR_Curtain_Gaseous_Attenuation, 'CPR Gaseous_Attenuation (GEOPROF)', 'int16', cs_trmm_hdf_id);

            write_sds(single(PR_Curtain_Latitude), 'PR Curtain Latitude', 'float', cs_trmm_hdf_id);
            write_sds(single(PR_Curtain_Longitude), 'PR Curtain Longitude', 'float', cs_trmm_hdf_id);
            write_sds(single(PR_Curtain_Time), 'PR Curtain Time', 'float', cs_trmm_hdf_id);
            write_sds(int16(PR_Curtain_Reflectivity), 'PR Reflectivity Curtain (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(PR_Curtain_Corrected_Z), 'PR Corrected Z Curtain (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(PR_Curtain_Rain_Rate), 'PR Rain Rate Curtain (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(int32(PR_Curtain_Scan_Indices), 'PR Curtain Scan Indices', 'int32', cs_trmm_hdf_id);
            write_sds(int32(PR_Curtain_Ray_Indices), 'PR Curtain Ray Indices', 'int32', cs_trmm_hdf_id);


            write_sds(single(PR_Block_Latitude), 'PR Block Latitude', 'float', cs_trmm_hdf_id);
            write_sds(single(PR_Block_Longitude), 'PR Block Longitude', 'float', cs_trmm_hdf_id);
            write_sds(single(PR_Block_Time), 'PR Block Time', 'float', cs_trmm_hdf_id);
            write_sds(int16(PR_Block_Reflectivity), 'PR Reflectivity Block (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(PR_Block_Rain_Rate), 'PR Rain Rate Block (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(PR_Block_Corrected_Z), 'PR Corrected Z Block (2A25)', 'int16', cs_trmm_hdf_id);

            % Write 1C21 Content
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/systemNoise', trmm_scan_block_range)), 'PR systemNoise (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int8(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/sysNoiseWarnFlag', trmm_scan_block_range)), 'PR sysNoiseWarnFlag (1C21)', 'int8', cs_trmm_hdf_id);
            write_sds(int8(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/minEchoFlag', trmm_scan_block_range)), 'PR minEchoFlag (1C21)', 'int8', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/binStormHeight', trmm_scan_block_range)), 'PR binStormHeight (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/binEllipsoid', trmm_scan_block_range)), 'PR binEllipsoid (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/binClutterFreeBottom', trmm_scan_block_range)), 'PR binClutterFreeBottom (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/binDIDHmean', trmm_scan_block_range)), 'PR binDIDHmean (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/binDIDHtop', trmm_scan_block_range)), 'PR binDIDHtop (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/binDIDHbottom', trmm_scan_block_range)), 'PR binDIDHbottom (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/scLocalZenith', trmm_scan_block_range)), 'PR scLocalZenith (1C21)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/scRange', trmm_scan_block_range)), 'PR scRange (1C21)', 'float', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/osBinStart', trmm_scan_block_range)), 'PR osBinStart (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/landOceanFlag', trmm_scan_block_range)), 'PR landOceanFlag (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/surfWarnFlag', trmm_scan_block_range)), 'PR surfWarnFlag (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/binSurfPeak', trmm_scan_block_range)), 'PR binSurfPeak (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/osSurf', trmm_scan_block_range)), 'PR osSurf (1C21)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_1C21_file, '/DATA_GRANULE/SwathData/osRain', trmm_scan_block_range)), 'PR osRain (1C21)', 'int16', cs_trmm_hdf_id);

            % Write 2A25 Content
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/scLocalZenith', trmm_scan_block_range)), 'PR scLocalZenith (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(int8(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/reliab', trmm_scan_block_range)), 'PR reliab (2A25)', 'int8', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/attenParmAlpha', trmm_scan_block_range)), 'PR attenParmAlpha (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/attenParmBeta', trmm_scan_block_range)), 'PR attenParmBeta (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/parmNode', trmm_scan_block_range)), 'PR parmNode (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/precipWaterParmA', trmm_scan_block_range)), 'PR precipWaterParmA (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/precipWaterParmB', trmm_scan_block_range)), 'PR precipWaterParmB (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/ZRParmA', trmm_scan_block_range)), 'PR ZRParmA (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/ZRParmB', trmm_scan_block_range)), 'PR ZRParmB (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/zmmax', trmm_scan_block_range)), 'PR zmmax (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/rainFlag', trmm_scan_block_range)), 'PR rainFlag (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/rangeBinNum', trmm_scan_block_range)), 'PR rangeBinNum (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/rainAve', trmm_scan_block_range)), 'PR rainAve (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/precipWaterSum', trmm_scan_block_range)), 'PR precipWaterSum (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/epsilon_0', trmm_scan_block_range)), 'PR epsilon_0 (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/method', trmm_scan_block_range)), 'PR method (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/epsilon', trmm_scan_block_range)), 'PR epsilon (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/zeta', trmm_scan_block_range)), 'PR zeta (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/zeta_mn', trmm_scan_block_range)), 'PR zeta_mn (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/zeta_sd', trmm_scan_block_range)), 'PR zeta_sd (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/sigmaZero', trmm_scan_block_range)), 'PR sigmaZero (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/freezH', trmm_scan_block_range)), 'PR freezH (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/nubfCorrectFactor', trmm_scan_block_range)), 'PR nubfCorrectFactor (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/qualityFlag', trmm_scan_block_range)), 'PR qualityFlag (2A25)', 'int16', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/nearSurfRain', trmm_scan_block_range)), 'PR nearSurfRain (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/nearSurfZ', trmm_scan_block_range)), 'PR nearSurfZ (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/e_SurfRain', trmm_scan_block_range)), 'PR e_SurfRain (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/pia', trmm_scan_block_range)), 'PR pia (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/errorRain', trmm_scan_block_range)), 'PR errorRain (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/spare', trmm_scan_block_range)), 'PR spare (2A25)', 'float', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A25_file, '/DATA_GRANULE/SwathData/rainType', trmm_scan_block_range)), 'PR rainType (2A25)', 'int16', cs_trmm_hdf_id);

            % Write 2A23 Content
            write_sds(int8(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/rainFlag', trmm_scan_block_range)), 'PR rainFlag (2A23)', 'int8', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/rainType', trmm_scan_block_range)), 'PR rainType (2A23)', 'int16', cs_trmm_hdf_id);
            write_sds(int8(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/shallowRain', trmm_scan_block_range)), 'PR shallowRain (2A23)', 'int8', cs_trmm_hdf_id);
            write_sds(int8(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/status', trmm_scan_block_range)), 'PR status (2A23)', 'int8', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/binBBpeak', trmm_scan_block_range)), 'PR binBBpeak (2A23)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/HBB', trmm_scan_block_range)), 'PR HBB (2A23)', 'int16', cs_trmm_hdf_id);
            write_sds(single(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/BBintensity', trmm_scan_block_range)), 'PR BBintensity (2A23)', 'float', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/freezH', trmm_scan_block_range)), 'PR freezH (2A23)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/stormH', trmm_scan_block_range)), 'PR stormH (2A23)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/spare', trmm_scan_block_range)), 'PR spare (2A23)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/BBboundary', trmm_scan_block_range)), 'PR BBboundary (2A23)', 'int16', cs_trmm_hdf_id);
            write_sds(int16(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/BBwidth', trmm_scan_block_range)), 'PR BBwidth (2A23)', 'int16', cs_trmm_hdf_id);
            write_sds(int8(get_block_PR(trmm_2A23_file, '/DATA_GRANULE/SwathData/BBstatus', trmm_scan_block_range)), 'PR BBstatus (2A23)', 'int8', cs_trmm_hdf_id);        

            status = hdfsd('end',cs_trmm_hdf_id);
            if status == -1
                error('error in endaccess to hdf file %s\n', cs_trmm_hdf_file);
            end


            %% WRITE VDATA OUTPUT
            % Read Geolocation Fields
            vlist = h4vsmultiread2cells(cs_file, '/2B-GEOPROF/Geolocation Fields/', ...
                    {'TAI_start', 'Range_to_intercept'}, 1);
            vlist = [vlist, h4vsmultiread2cells(cs_file, '/2B-GEOPROF/Geolocation Fields/', ...
                               {'DEM_elevation'}, cs_curtain_range)];
            vlist = [vlist, h4vsmultiread2cells(cs_file, '/2B-GEOPROF/Geolocation Fields/', ...
                               {'Vertical_binsize', 'Pitch_offset', 'Roll_offset'}, 1)];
            % Read Data Fields
            vlist = [vlist, h4vsmultiread2cells(cs_file, '/2B-GEOPROF/Data Fields/', ...
                               {'Data_quality', 'Data_status', 'Data_targetID', 'SurfaceHeightBin', 'SurfaceHeightBin_fraction'}, ...
                                cs_curtain_range)];
            h4vswrite(cs_trmm_hdf_file, vlist, 'write');

            % CS Stuffs
            % This is a dirty trick to reuse the function, since struct's name
            % is similarly to variable's name
            h4vs1write(cs_trmm_hdf_file, 'Sigma-Zero', h4vsread2mat(cs_file, '/2B-GEOPROF/Data Fields/', 'Sigma-Zero', cs_curtain_range), 'write');
            vlist = h4vsmultiread2cells(cs_file, '/2B-GEOPROF/Data Fields/', ...
                     {'MODIS_cloud_flag', 'MODIS_Cloud_Fraction', 'MODIS_scene_char', 'MODIS_scene_var', ...
                     'CPR_Echo_Top', 'sem_NoiseFloor', 'sem_NoiseFloorVar', 'sem_NoiseGate', ...
                     'Navigation_land_sea_flag', 'Clutter_reduction_flag'}, cs_curtain_range);
            h4vswrite(cs_trmm_hdf_file, vlist, 'write');

            h4vs1write(cs_trmm_hdf_file, 'nray:2B-GEOPROF', nray, 'write');
            h4vs1write(cs_trmm_hdf_file, 'nbin:2B-GEOPROF', nbin, 'write');
            
            % TRMM Stuffs
            vlist = h4vs1fields2cells(trmm_1C21_file, 'PR_CAL_COEF', '/DATA_GRANULE/PR_CAL_COEF', {'transCoef', 'receptCoef'}, 1); %TODO: missing fcifIOchar
            vlist = [vlist, h4vs1fields2cells(trmm_1C21_file, 'RAY_HEADER', '/DATA_GRANULE/RAY_HEADER', ...
                                        {'rayStart', 'raySize', 'angle', 'startBinDist', 'rainThres1', 'rainThres2', ...
                                        'transAntenna', 'recvAntenna', 'onewayAlongTrack', 'onewayCrossTrack', 'eqvWavelength', ...
                                        'radarConst', 'prIntrDelay', 'rangeBinSize', 'logAveOffset', 'mainlobeEdge'}, [1:49])]; %TODO: missing sidelobeRange
            vlist = [vlist, h4vs1fields2cells(trmm_1C21_file, 'pr_scan_status', '/DATA_GRANULE/SwathData/pr_scan_status', ...
                                        {'missing', 'validity', 'qac', 'geoQuality', 'dataQuality', 'scOrient', ...
                                        'acsMode', 'yawUpdateS', 'prMode', 'prStatus1', 'prStatus2', ...
                                        'fractOrbitN'}, trmm_scan_block_range)];
            vlist = [vlist, h4vs1fields2cells(trmm_1C21_file, 'pr_navigation', '/DATA_GRANULE/SwathData/pr_navigation', ...
                                        {'scPosX', 'scPosY', 'scPosZ', 'scVelX', 'scVelY', 'scVelZ', ...
                                        'scLat', 'scLon', 'scAlt', 'scAttRoll', 'scAttPitch', 'scAttYaw', ...
                                        'greenHourAng'}, trmm_scan_block_range)]; %TODO 2nd from last missing SensorOrientationMatrix
            vlist = [vlist, h4vs1fields2cells(trmm_1C21_file, 'powers', '/DATA_GRANULE/SwathData/powers', ...
                                        {'radarTransPower', 'transPulseWidth'}, trmm_scan_block_range)];
            h4vswrite(cs_trmm_hdf_file, vlist, 'write');
            fprintf('ending exporting with status %i\n', status);
        end
%         break;
    end
end

