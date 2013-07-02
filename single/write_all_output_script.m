    %trmm_1C21_dir = 'C:\school\data\trmm-2010-day-60\1C21\';
    %trmm_2A25_dir = 'C:\school\data\trmm-2010-day-60\2A25\';
    %trmm_2A23_dir = 'C:\school\data\trmm-2010-day-60\2A23\';
    % TODO: This section will be either moved to the
    % scanning above or implemented as a function
    % Find the pairing for TRMM and CS in this intersection curtain
    noOfIntersections = length(intersections);
    
    for iIndex = 1:noOfIntersections
        % Prepare info for this intersection
        intersection = intersections(iIndex);
        
        cs_file = intersection.cs_filename;
        trmm_file = intersection.trmm_filename;
        amsre_file = intersection.amsr_e_filename;
        tmi_file = intersection.tmi_filename;
        
        % Extract Information from Filenames of Satellites
        % CloudSat: 2007002013457_03622_CS_2B-GEOPROF_GRANULE_B11_R05_E02.HDF
        cs_filename_extract_pattern = '(\d\d\d\d)(\d\d\d)(\d\d)(\d\d)(\d\d)_(\d\d\d\d\d)';
        cs_filename_extract_tokens = regexp(cs_file, cs_filename_extract_pattern, 'tokens');
        cs_filename_extract_tokens = cs_filename_extract_tokens{1,1};

        % TRMM-1C21: 1C21.20070102.52028.7.HDF
        trmm_filename_extract_pattern = '1C21\.(\d\d\d\d)(\d\d)(\d\d)\.(\d\d\d\d\d)';
        trmm_filename_extract_tokens = regexp(trmm_file, trmm_filename_extract_pattern, 'tokens');
        trmm_filename_extract_tokens = trmm_filename_extract_tokens{1,1};
        
        % Find Filenames of other TRMM Instruments 
        trmm_1C21_file = trmm_file;
        trmm_2A23_file = regexprep(trmm_file, '1C21', '2A23');
        trmm_2A25_file = regexprep(trmm_file, '1C21', '2A25');
        
        % Find Filenames of other TMI Instruments
        tmi_1B11_file = tmi_file;
        tmi_2A12_file = regexprep(tmi_file, '1B11', '2A12');
        
        CS_Geolocation_Fields = '/2B-GEOPROF/Geolocation Fields/';
        CS_Data_Fields = '/2B-GEOPROF/Data Fields/';
        AMSRE_Geolocation_Fields = '/Low_Res_Swath/Geolocation Fields/';
        AMSRE_Data_Fields = '/Low_Res_Swath/Data Fields/';
        
        % curtain_indexes has 1 row as center of intersection & the
        % remaining row of matching CS-TRMM scans
        curtain_indexes = intersection.curtain_indexes;
        CS_ICenter_Index = curtain_indexes(1,1);
        TRMM_ICenter_Index = curtain_indexes(1,2);
        CS_TRMM_curtain_pairs = curtain_indexes(2:size(curtain_indexes,1), :);
        CS_TRMM_curtain_length = size(CS_TRMM_curtain_pairs, 1);
             
        %% FILENAME Construction
        % Extraction of Basic Components for construction of Output Filename
        % CloudSat Data
        CS_Time = int32(h4vsread2mat(cs_file, CS_Geolocation_Fields, 'Profile_time'));
        CS_UTC_Start = int32(h4vsread2mat(cs_file, CS_Geolocation_Fields, 'UTC_start'));
        CS_Latitude = h4vsread2mat(cs_file, CS_Geolocation_Fields, 'Latitude');
        CS_Longitude = h4vsread2mat(cs_file, CS_Geolocation_Fields, 'Longitude');
        CS_Reflectivity = hdfread(cs_file, '/2B-GEOPROF/Data Fields/Radar_Reflectivity');
        CS_Cloud_mask = hdfread(cs_file, '/2B-GEOPROF/Data Fields/CPR_Cloud_mask');
        CS_Scan_Length = length(CS_Time);
        
        % TRMM Data
        TRMM_1C21_Latitude = hdfread(trmm_1C21_file, '/Swath/Latitude');
        TRMM_1C21_Longitude = hdfread(trmm_1C21_file, '/Swath/Latitude');
        TRMM_1C21_Reflectivity = hdfread(trmm_1C21_file, '/Swath/normalSample');
        TRMM_2A25_Corrected_Z =  hdfread(trmm_2A25_file, '/Swath/correctZFactor');
        TRMM_2A25_Rain_Rate = hdfread(trmm_2A25_file, '/Swath/rain');
        TRMM_1C21_OS_Rain = hdfread(trmm_file, '/Swath/osRain');
        
        % Convert PR Time to CPR Centric time
        TRMM_Time = trmm2csTime(trmm_file, str2num(cs_filename_extract_tokens{2}), CS_UTC_Start); 
        TRMM_Scan_Length = length(TRMM_Time);
        
        % Context Scans of CS and TRMM
        CS_Curtain_Range = CS_TRMM_curtain_pairs(1,1):CS_TRMM_curtain_pairs(CS_TRMM_curtain_length,1);
        CS_Context_Range = max((CS_TRMM_curtain_pairs(1,1)-50), 1):min((CS_TRMM_curtain_pairs(CS_TRMM_curtain_length,1)+50), CS_Scan_Length);
        
        if CS_TRMM_curtain_pairs(1,2) > CS_TRMM_curtain_pairs(CS_TRMM_curtain_length,2)
            TRMM_Curtain_Range = min((CS_TRMM_curtain_pairs(1,2)), TRMM_Scan_Length) :-1:max((CS_TRMM_curtain_pairs(CS_TRMM_curtain_length,2)),1);
            TRMM_Context_Range = min((CS_TRMM_curtain_pairs(1,2)+10), TRMM_Scan_Length) :-1:max((CS_TRMM_curtain_pairs(CS_TRMM_curtain_length,2)-10),1);
        else
            TRMM_Curtain_Range = max((CS_TRMM_curtain_pairs(1,2)), 1):1:min((CS_TRMM_curtain_pairs(CS_TRMM_curtain_length,2)), TRMM_Scan_Length);
            TRMM_Context_Range = max((CS_TRMM_curtain_pairs(1,2)-10), 1):1:min((CS_TRMM_curtain_pairs(CS_TRMM_curtain_length,2)+10), TRMM_Scan_Length);
        end
        
        
        CS_Curtain_Reflectivity = CS_Reflectivity(CS_Curtain_Range, :);
        CS_Curtain_Cloud_mask = CS_Cloud_mask(CS_Curtain_Range, :);
        
        TRMM_1C21_Curtain_OS_Rain = TRMM_1C21_OS_Rain(TRMM_Curtain_Range, :, :);
        TRMM_1C21_Curtain_Latitude = zeros(CS_TRMM_curtain_length, 1);
        TRMM_1C21_Curtain_Longitude = zeros(CS_TRMM_curtain_length, 1);
        TRMM_Curtain_Time = zeros(CS_TRMM_curtain_length, 1);
        TRMM_1C21_Curtain_Reflectivity = zeros(CS_TRMM_curtain_length, size(TRMM_1C21_Reflectivity, 3));
        TRMM_2A25_Curtain_Corrected_Z = zeros(CS_TRMM_curtain_length, size(TRMM_2A25_Corrected_Z, 3));
        TRMM_2A25_Curtain_Rain_Rate = zeros(CS_TRMM_curtain_length, size(TRMM_2A25_Rain_Rate, 3));
       
        TRMM_Curtain_Scan_Indices = CS_TRMM_curtain_pairs(:, 2);
        TRMM_Curtain_Ray_Indices = CS_TRMM_curtain_pairs(:, 3);
        for i = 1:CS_TRMM_curtain_length
            TRMM_1C21_Curtain_Latitude(i,1) = TRMM_1C21_Latitude(CS_TRMM_curtain_pairs(i, 2), CS_TRMM_curtain_pairs(i, 3));
            TRMM_1C21_Curtain_Longitude(i,1) = TRMM_1C21_Latitude(CS_TRMM_curtain_pairs(i, 2), CS_TRMM_curtain_pairs(i, 3));
            TRMM_Curtain_Time(i,1) = TRMM_Time(CS_TRMM_curtain_pairs(i,2));
            TRMM_1C21_Curtain_Reflectivity(i, :) = TRMM_1C21_Reflectivity(CS_TRMM_curtain_pairs(i, 2), CS_TRMM_curtain_pairs(i, 3), :);
            TRMM_2A25_Curtain_Rain_Rate(i, :) = TRMM_2A25_Rain_Rate(CS_TRMM_curtain_pairs(i, 2), CS_TRMM_curtain_pairs(i, 3), :);
            TRMM_2A25_Curtain_Corrected_Z(i, :) = TRMM_2A25_Corrected_Z(CS_TRMM_curtain_pairs(i, 2), CS_TRMM_curtain_pairs(i, 3), :);
        end
        
        % Process CloudSat Time
        cs_center_time = CS_Time(CS_ICenter_Index) + CS_UTC_Start;
        cs_center_second = mod(cs_center_time, 60);
        cs_center_minute = mod((cs_center_time - cs_center_second)/60, 60);
        cs_center_hour = ((cs_center_time - cs_center_second)/60 - cs_center_minute)/60;
        cs_center_time_str = time2str(cs_center_hour, cs_center_minute, round(cs_center_second));
        
        % Process Overpass Time
        dt_num = CS_Time(CS_ICenter_Index) - TRMM_Time(TRMM_ICenter_Index);
        filename_dt_num = round(dt_num/60);
        if filename_dt_num > 0 % PR First
            filename_dt = sprintf('%02d%s', filename_dt_num, 'T');
        else % CPR First
            filename_dt = sprintf('%02d%s', abs(filename_dt_num), 'C');
        end
        
        % Process CloudSat Lat and Lon at Center
        if CS_Longitude(CS_ICenter_Index) > 0
            LT = sprintf('%02d%s', round(CS_Longitude(CS_ICenter_Index)), 'N');
        else
            LT = sprintf('%03d%s', abs(round(CS_Longitude(CS_ICenter_Index))), 'S');
        end
        if CS_Longitude(CS_ICenter_Index) > 0
            LG = sprintf('%02d%s', round(CS_Longitude(CS_ICenter_Index)), 'E');
        else
            LG = sprintf('%03d%s', abs(round(CS_Longitude(CS_ICenter_Index))), 'W');
        end

        % ABCDE section
        % A TODO: missing sum(sum(sum(osRain == -32700)))
        A = sum(sum(sum(TRMM_1C21_Curtain_OS_Rain ~= -32700)));
        A = A/(size(TRMM_1C21_Curtain_OS_Rain, 1) * size(TRMM_1C21_Curtain_OS_Rain, 2) * size(TRMM_1C21_Curtain_OS_Rain, 3));
        A = ceil(A/5);
        if A <= 9
            A = num2str(A);
        else
            A = 'a';
        end
        
        % B
        B = max(max(TRMM_2A25_Curtain_Rain_Rate));
        B = ceil(B/5);
        if B <= 9
            B = num2str(B);
        else
            B = 'a';
        end
        
        % C
        C = max(max(CS_Curtain_Reflectivity));
        if C <= -20
            C = '0';
        elseif C <= -30
            C = '1';
        elseif C <= -20
            C = '2';
        elseif C <= -10
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
        D = max(max(TRMM_2A25_Curtain_Corrected_Z));
        D = ceil(D / 8);
        if D > 9
            D = 'a';
        else
            D = num2str(D);
        end
        
       
        % E
        E = sum(sum(logical(20 <= CS_Curtain_Cloud_mask & CS_Curtain_Cloud_mask <= 40))) / (size(CS_Curtain_Cloud_mask,1) * size(CS_Curtain_Cloud_mask,2));
        E = ceil(E/0.1);
        if E <= 9
            E = num2str(E);
        else
            E = 'a';
        end
        
        % Final Filename    
        cs_trmm_filename = sprintf('%s%s%s_%s_%s_%s_%s%s%s%s%s_%s_CS_%s_TR.hdf', ...
            cs_filename_extract_tokens{1}, cs_filename_extract_tokens{2}, cs_center_time_str, filename_dt, LT, LG, A, B, C, D, E, ... 
            cs_filename_extract_tokens{6}, trmm_filename_extract_tokens{4});
        fprintf('%d. Filename = %s\n', iIndex ,cs_trmm_filename);
        
        
        %% Write Output
        % WRITE SDS OUTPUT
        % Open file for SD
        cs_trmm_hdf_file = sprintf('%s%s', output_dir, cs_trmm_filename);
        cs_trmm_hdf_id = hdfsd('start', cs_trmm_hdf_file, 'DFACC_CREATE');
        
        CS_Context_Height = hdfread(cs_file, '/2B-GEOPROF/Geolocation Fields/Height');
        CS_Context_Height = CS_Context_Height(CS_Context_Range, :);
        CS_Context_Latitude = CS_Latitude(CS_Context_Range);
        CS_Context_Longitude = CS_Longitude(CS_Context_Range);
        CS_Context_Time = CS_Time(CS_Context_Range);
        CS_Context_Gaseous_Attenuation = hdfread(cs_file, '/2B-GEOPROF/Data Fields/Gaseous_Attenuation');
        CS_Context_Gaseous_Attenuation = CS_Context_Gaseous_Attenuation(CS_Context_Range, :);
        
        TRMM_1C21_Context_Latitude = TRMM_1C21_Latitude(TRMM_Context_Range, :);
        TRMM_1C21_Context_Longitude = TRMM_1C21_Latitude(TRMM_Context_Range, :);
        TRMM_Context_Time = TRMM_Time(1, TRMM_Context_Range)';
        
        [nray, nbin] = size(CS_Context_Height);
        
        % PR 2A25 Content
        TRMM_2A25_Context_Rain_Rate = get_block_PR(trmm_2A25_file, '/Swath/rain', TRMM_Context_Range);
        TRMM_2A25_Context_Corrected_Z = get_block_PR(trmm_2A25_file, '/Swath/correctZFactor', TRMM_Context_Range);
        TRMM_2A25_Context_Reflectivity = get_block_PR(trmm_1C21_file, '/Swath/normalSample', TRMM_Context_Range);      
        
        %% Writing
        write_sds(CS_Context_Height, 'CPR Height', 'int16', cs_trmm_hdf_id);
        write_sds(CS_Context_Latitude, 'CPR Latitude', 'float', cs_trmm_hdf_id);
        write_sds(CS_Context_Longitude, 'CPR Longitude', 'float', cs_trmm_hdf_id);
        write_sds(CS_Context_Time, 'CPR Time', 'int32', cs_trmm_hdf_id);
        write_sds(CS_Curtain_Reflectivity, 'CPR Reflectivity(GEOPROF)', 'int16', cs_trmm_hdf_id);
        write_sds(CS_Curtain_Cloud_mask, 'CPR Cloud_Mask(GEOPROF)', 'int8', cs_trmm_hdf_id);
        write_sds(CS_Context_Gaseous_Attenuation, 'CPR Gaseous_Attenuation(GEOPROF)', 'int16', cs_trmm_hdf_id);

        write_sds(single(TRMM_1C21_Curtain_Latitude), 'PR Curtain Latitude', 'float', cs_trmm_hdf_id);
        write_sds(single(TRMM_1C21_Curtain_Longitude), 'PR Curtain Longitude', 'float', cs_trmm_hdf_id);
        write_sds(single(TRMM_Curtain_Time), 'PR Curtain Time', 'float', cs_trmm_hdf_id);
        write_sds(int16(TRMM_1C21_Curtain_Reflectivity), 'PR Reflectivity Curtain(1C21)', 'int16', cs_trmm_hdf_id);
        write_sds(int16(TRMM_2A25_Curtain_Corrected_Z), 'PR Corrected Z Curtain(2A25)', 'int16', cs_trmm_hdf_id);
        write_sds(int16(TRMM_2A25_Curtain_Rain_Rate), 'PR Rain Rate Curtain(2A25)', 'int16', cs_trmm_hdf_id);
        write_sds(int32(TRMM_Curtain_Scan_Indices), 'PR Curtain Scan Indices', 'int32', cs_trmm_hdf_id);
        write_sds(int32(TRMM_Curtain_Ray_Indices), 'PR Curtain Ray Indices', 'int32', cs_trmm_hdf_id);

        write_sds(single(TRMM_1C21_Context_Latitude), 'PR Block Latitude', 'float', cs_trmm_hdf_id);
        write_sds(single(TRMM_1C21_Context_Longitude), 'PR Block Longitude', 'float', cs_trmm_hdf_id);
        write_sds(single(TRMM_Context_Time), 'PR Block Time', 'float', cs_trmm_hdf_id);
        write_sds(int16(TRMM_2A25_Context_Reflectivity), 'PR Reflectivity Block(1C21)', 'int16', cs_trmm_hdf_id);
        write_sds(int16(TRMM_2A25_Context_Rain_Rate), 'PR Rain Rate Block(2A25)', 'int16', cs_trmm_hdf_id);
        write_sds(int16(TRMM_2A25_Context_Corrected_Z), 'PR Corrected Z Block(2A25)', 'int16', cs_trmm_hdf_id);

        TRMM_1C21_SDS_CONTENTS = {{'/Swath/systemNoise', 'PR systemNoise(1C21)', 'int16'},...
                                  {'/Swath/sysNoiseWarnFlag', 'PR sysNoiseWarnFlag(1C21)', 'int8'},...
                                  {'/Swath/minEchoFlag', 'PR minEchoFlag(1C21)', 'int8'},...
                                  {'/Swath/binStormHeight', 'PR binStormHeight(1C21)', 'int16'},...
                                  {'/Swath/binEllipsoid', 'PR binEllipsoid(1C21)', 'int16'},...
                                  {'/Swath/binClutterFreeBottom', 'PR binClutterFreeBottom(1C21)', 'int16'},...
                                  {'/Swath/binDIDHmean', 'PR binDIDHmean(1C21)', 'int16'},...
                                  {'/Swath/binDIDHtop', 'PR binDIDHtop(1C21)', 'int16'},...
                                  {'/Swath/binDIDHbottom', 'PR binDIDHbottom(1C21)', 'int16'},...
                                  {'/Swath/scLocalZenith', 'PR scLocalZenith(1C21)', 'float'},...
                                  {'/Swath/scRange', 'PR scRange(1C21)', 'float'},...
                                  {'/Swath/osBinStart', 'PR osBinStart(1C21)', 'int16'},...
                                  {'/Swath/landOceanFlag', 'PR landOceanFlag(1C21)', 'int16'},...
                                  {'/Swath/surfWarnFlag', 'PR surfWarnFlag(1C21)', 'int16'},...
                                  {'/Swath/binSurfPeak', 'PR binSurfPeak(1C21)', 'int16'},...
                                  {'/Swath/osSurf', 'PR osSurf(1C21)', 'int16'},...
                                  {'/Swath/osRain', 'PR osRain(1C21)', 'int16'}};
                                  
        TRMM_2A25_SDS_CONTENTS = {{'/Swath/scLocalZenith', 'PR scLocalZenith(2A25)', 'float'},...
                                  {'/Swath/reliab', 'PR reliab(2A25)', 'int8'},...
                                  {'/Swath/attenParmAlpha', 'PR attenParmAlpha(2A25)', 'float'},...
                                  {'/Swath/attenParmBeta', 'PR attenParmBeta(2A25)', 'float'},...
                                  {'/Swath/parmNode', 'PR parmNode(2A25)', 'int16'},...
                                  {'/Swath/precipWaterParmA', 'PR precipWaterParmA(2A25)', 'float'},...
                                  {'/Swath/precipWaterParmB', 'PR precipWaterParmB(2A25)', 'float'},...
                                  {'/Swath/ZRParmA', 'PR ZRParmA(2A25)', 'float'},...
                                  {'/Swath/ZRParmB', 'PR ZRParmB(2A25)', 'float'},...
                                  {'/Swath/zmmax', 'PR zmmax(2A25)', 'float'},...
                                  {'/Swath/rainFlag', 'PR rainFlag(2A25)', 'int16'},...
                                  {'/Swath/rangeBinNum', 'PR rangeBinNum(2A25)', 'int16'},...
                                  {'/Swath/rainAve', 'PR rainAve(2A25)', 'float'},...
                                  {'/Swath/precipWaterSum', 'PR precipWaterSum(2A25)', 'float'},...
                                  {'/Swath/epsilon_0', 'PR epsilon_0(2A25)', 'float'},...
                                  {'/Swath/method', 'PR method(2A25)', 'int16'},...
                                  {'/Swath/epsilon', 'PR epsilon(2A25)', 'float'},...
                                  {'/Swath/zeta', 'PR zeta(2A25)', 'float'},...
                                  {'/Swath/zeta_mn', 'PR zeta_mn(2A25)', 'float'},...
                                  {'/Swath/zeta_sd', 'PR zeta_sd(2A25)', 'float'},...
                                  {'/Swath/sigmaZero', 'PR sigmaZero(2A25)', 'float'},...
                                  {'/Swath/freezH', 'PR freezH(2A25)', 'float'},...
                                  {'/Swath/nubfCorrectFactor', 'PR nubfCorrectFactor(2A25)', 'float'},...
                                  {'/Swath/qualityFlag', 'PR qualityFlag(2A25)', 'int16'},...
                                  {'/Swath/nearSurfRain', 'PR nearSurfRain(2A25)', 'float'},...
                                  {'/Swath/nearSurfZ', 'PR nearSurfZ(2A25)', 'float'},...
                                  {'/Swath/e_SurfRain', 'PR e_SurfRain(2A25)', 'float'},...
                                  {'/Swath/pia', 'PR pia(2A25)', 'float'},...
                                  {'/Swath/errorRain', 'PR errorRain(2A25)', 'float'},...
                                  {'/Swath/spare', 'PR spare(2A25)', 'float'},...
                                  {'/Swath/rainType', 'PR rainType(2A25)', 'int16'}};
         
        TRMM_2A23_SDS_CONTENTS = {{'/Swath/rainFlag', 'PR rainFlag(2A23)', 'int8'},...
                                  {'/Swath/rainType', 'PR rainType(2A23)', 'int16'},...
                                  {'/Swath/shallowRain', 'PR shallowRain(2A23)', 'int8'},...
                                  {'/Swath/status', 'PR status(2A23)', 'int8'},...
                                  {'/Swath/binBBpeak', 'PR binBBpeak(2A23)', 'int16'},...
                                  {'/Swath/HBB', 'PR HBB(2A23)', 'int16'},...
                                  {'/Swath/BBintensity', 'PR BBintensity(2A23)', 'float'},...
                                  {'/Swath/freezH', 'PR freezH(2A23)', 'int16'},...
                                  {'/Swath/stormH', 'PR stormH(2A23)', 'int16'},...
                                  {'/Swath/spare', 'PR spare(2A23)', 'int16'},...
                                  {'/Swath/BBboundary', 'PR BBboundary(2A23)', 'int16'},...
                                  {'/Swath/BBwidth', 'PR BBwidth(2A23)', 'int16'},...
                                  {'/Swath/BBstatus', 'PR BBstatus(2A23)', 'int8'}
                                  };
                              
        % Write 1C21 Content
        for cindex=1:length(TRMM_1C21_SDS_CONTENTS)
            trmm_1C21_path = TRMM_1C21_SDS_CONTENTS{cindex}{1};
            trmm_INT_path = TRMM_1C21_SDS_CONTENTS{cindex}{2};
            trmm_INT_type = TRMM_1C21_SDS_CONTENTS{cindex}{3};
            write_sds(get_block_PR(trmm_1C21_file, trmm_1C21_path, TRMM_Context_Range), trmm_INT_path, trmm_INT_type, cs_trmm_hdf_id);
        end
        
        % Write 2A25 Content
        for cindex=1:length(TRMM_2A25_SDS_CONTENTS)
            trmm_2A25_path = TRMM_2A25_SDS_CONTENTS{cindex}{1};
            trmm_INT_path = TRMM_2A25_SDS_CONTENTS{cindex}{2};
            trmm_INT_type = TRMM_2A25_SDS_CONTENTS{cindex}{3};
            write_sds(get_block_PR(trmm_2A25_file, trmm_2A25_path, TRMM_Context_Range), trmm_INT_path, trmm_INT_type, cs_trmm_hdf_id);
        end

        % Write 2A23 Content
        for cindex=1:length(TRMM_2A23_SDS_CONTENTS)
            trmm_2A23_path = TRMM_2A23_SDS_CONTENTS{cindex}{1};
            trmm_INT_path = TRMM_2A23_SDS_CONTENTS{cindex}{2};
            trmm_INT_type = TRMM_2A23_SDS_CONTENTS{cindex}{3};
            write_sds(get_block_PR(trmm_2A23_file, trmm_2A23_path, TRMM_Context_Range), trmm_INT_path, trmm_INT_type, cs_trmm_hdf_id);
        end
        
        
        % Write TMI 1B11 Content
        TMI_Context_Range = min(intersection.amsr_e_tmi(:, 3)):max(intersection.amsr_e_tmi(:, 3));
        AMSRE_Context_Range = min(intersection.amsr_e_tmi(:, 1)):max(intersection.amsr_e_tmi(:, 1));
        
        TMI_Time = trmm2csTime(tmi_1B11_file, str2num(cs_filename_extract_tokens{2}), CS_UTC_Start);
        TMI_Context_Time = TMI_Time(TMI_Context_Range);
        TMI_1B11_Latitude = hdfread(tmi_1B11_file, '/Swath/Latitude');
        TMI_1B11_Longitude = hdfread(tmi_1B11_file, '/Swath/Longitude');
        
        AMSRE_Time = h4vsread2mat(amsre_file, AMSRE_Geolocation_Fields, 'Time'); %TODO: CONVERT TO CS CENTRIC
        AMSRE_Context_Time = AMSRE_Time(AMSRE_Context_Range);
        AMSRE_Latitude = hdfread(amsre_file, sprintf('%s%s', AMSRE_Geolocation_Fields, 'Latitude'));
        AMSRE_Longitude = hdfread(amsre_file, sprintf('%s%s', AMSRE_Geolocation_Fields, 'Longitude'));

        write_sds(AMSRE_Context_Time, 'AMSR E Latitude', 'double', cs_trmm_hdf_id);
        write_sds(AMSRE_Latitude(AMSRE_Context_Range, :), 'AMSR E Latitude', 'float', cs_trmm_hdf_id);
        write_sds(AMSRE_Longitude(AMSRE_Context_Range, :), 'AMSR E Longitude', 'float', cs_trmm_hdf_id);
        
        AMSRE_SDS_CONTENTS = {{'/Low_Res_Swath/Data Fields/Antenna_Temp_Coefficients_6_to_52', 'AMSR E Antenna_Temp_Coefficients_6_to_52', 'float'},...
                              {'/Low_Res_Swath/Data Fields/Data_Quality', 'AMSR E Data_Quality', 'float'},...
                              ...%{'/Low_Res_Swath/Data Fields/SPS_Temperature_Count', 'AMSR E SPS_Temperature_Count', 'uint16'},...
                              ...%{'/Low_Res_Swath/Data Fields/Interpolation_Flag_6_to_52', 'AMSR E Interpolation_Flag', 'int16'},...
                              ...%{'/Low_Res_Swath/Data Fields/Observation_Supplement', 'AMSR E Observation_Supplement', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/Navigation_Data', 'AMSR E Navigation_Data', 'float'},...
                              {'/Low_Res_Swath/Data Fields/Attitude_Data', 'AMSR E Attitude_Data', 'float'},...
                              ...%{'/Low_Res_Swath/Data Fields/SPC_Temperature_Count', 'AMSR E SPC_Temperature_Count', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/Earth_Incidence', 'AMSR E Earth_Incidence', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/Earth_Azimuth', 'AMSR E Earth_Azimuth', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/Sun_Elevation', 'AMSR E Sun_Elevation', 'int16'},...
                              ...%{'/Low_Res_Swath/Data Fields/Rx_Offset/Gain_Count', 'AMSR E Rx_Offset/Gain_Count', 'int16'},...
                              ...%{'/Low_Res_Swath/Data Fields/Land/Ocean_Flag_for_6_10_18_23_36_50_89A', 'AMSR E Land/Ocean_Flag_for_6_10_18_23_36_50_89A', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/Cold_Sky_Mirror_Count_6_to_52', 'AMSR E Cold_Sky_Mirror_Count_6_to_52', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/Hot_Load_Count_6_to_52', 'AMSR E Hot_Load_Count_6_to_52', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/6.9V_Res.1_TB_(not-resampled)', 'AMSR E 6.9V_Res.1_TB_(not-resampled)', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/6.9H_Res.1_TB_(not-resampled)', 'AMSR E 6.9H_Res.1_TB_(not-resampled)', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/10.7V_Res.2_TB_(not-resampled)', 'AMSR E 10.7V_Res.2_TB_(not-resampled)', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/10.7H_Res.2_TB_(not-resampled)', 'AMSR E 10.7H_Res.2_TB_(not-resampled)', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/18.7V_Res.3_TB_(not-resampled)', 'AMSR E /18.7V_Res.3_TB_(not-resampled)', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/18.7H_Res.3_TB_(not-resampled)', 'AMSR E 18.7H_Res.3_TB_(not-resampled)', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/23.8V_Approx._Res.3_TB_(not-resampled)', 'AMSR E 23.8V_Approx._Res.3_TB_(not-resampled)', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/23.8H_Approx._Res.3_TB_(not-resampled)', 'AMSR E 23.8H_Approx._Res.3_TB_(not-resampled)', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/36.5V_Res.4_TB_(not-resampled)', 'AMSR E 36.5V_Res.4_TB_(not-resampled)', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/36.5H_Res.4_TB_(not-resampled)', 'AMSR E 36.5H_Res.4_TB_(not-resampled)', 'int16'},...
                              ...%{'/Low_Res_Swath/Data Fields/DataTrack_lo:Low_Res_Swath', 'AMSR E DataTrack_lo:Low_Res_Swath', 'int16'},...
                              ...%{'/Low_Res_Swath/Data Fields/DataTrack_lo:Low_Res_Swath', 'AMSR E DataTrack_lo:Low_Res_Swath', 'int16'},...
                              {'/Low_Res_Swath/Data Fields/6.9H_Res.1_TB', 'AMSR E 6.9H_Res.1_TB', 'int16'}
                              };
        
        % Write AMSR E Content
        for cindex=1:length(AMSRE_SDS_CONTENTS)
            org_path = AMSRE_SDS_CONTENTS{cindex}{1};
            INT_path = AMSRE_SDS_CONTENTS{cindex}{2};
            INT_type = AMSRE_SDS_CONTENTS{cindex}{3};
            write_sds(get_block_PR(amsre_file, org_path, AMSRE_Context_Range), INT_path, INT_type, cs_trmm_hdf_id);
        end           
        
        write_sds(single(TRMM_1C21_Curtain_Latitude), 'PR Curtain Latitude', 'float', cs_trmm_hdf_id);
        write_sds(single(TRMM_1C21_Curtain_Longitude), 'PR Curtain Longitude', 'float', cs_trmm_hdf_id);
        write_sds(single(TRMM_Curtain_Time), 'PR Curtain Time', 'float', cs_trmm_hdf_id);

        TMI_1B11_SDS_CONTENTS = { {'/Swath/calCounts', 'TMI calCounts(1B11)', 'int16'},...
                                  {'/Swath/satLocZenAngle', 'TMI satLocZenAngle(1B11)', 'float'},...
                                  {'/Swath/lowResCh', 'TMI lowResCh(1B11)', 'int16'},...
                                  {'/Swath/highResCh', 'TMI highResCh(1B11)', 'int16'}
                                  };
                              
        % Write 1B11 Content
        for cindex=1:length(TMI_1B11_SDS_CONTENTS)
            tmi_1B11_path = TMI_1B11_SDS_CONTENTS{cindex}{1};
            tmi_INT_path = TMI_1B11_SDS_CONTENTS{cindex}{2};
            tmi_INT_type = TMI_1B11_SDS_CONTENTS{cindex}{3};
            write_sds(get_block_PR(tmi_1B11_file, tmi_1B11_path, TMI_Context_Range), tmi_INT_path, tmi_INT_type, cs_trmm_hdf_id);
        end
        
        TMI_2A12_SDS_CONTENTS = { {'/Swath/qualityFlag', 'TMI qualityFlag(2A12)', 'int8'},...
                                  {'/Swath/pixelStatus', 'TMI pixelStatus(2A12)', 'int8'},...
                                  {'/Swath/surfaceType', 'TMI surfaceType(2A12)', 'int8'},...
                                  {'/Swath/landAmbiguousFlag', 'TMI landAmbiguousFlag(2A12)', 'int8'}...
                                  {'/Swath/landScreenFlag', 'TMI landScreenFlag(2A12)', 'int8'},...
                                  {'/Swath/oceanExtendedDbase', 'TMI oceanExtendedDbase(2A12)', 'int8'},...
                                  {'/Swath/oceanSearchRadius', 'TMI oceanSearchRadius(2A12)', 'int8'},...
                                  {'/Swath/chiSquared', 'TMI chiSquared(2A12)', 'int16'},...
                                  {'/Swath/probabilityOfPrecip', 'TMI probabilityOfPrecip(2A12)', 'int8'},...
                                  {'/Swath/freezingHeight', 'TMI freezingHeight(2A12)', 'int16'},...
                                  {'/Swath/surfacePrecipitation', 'TMI surfacePrecipitation(2A12)', 'float'},...
                                  {'/Swath/convectPrecipitation', 'TMI convectPrecipitation(2A12)', 'float'},...
                                  {'/Swath/cloudWaterPath', 'TMI cloudWaterPath(2A12)', 'float'},...
                                  {'/Swath/rainWaterPath', 'TMI rainWaterPath(2A12)', 'float'},...
                                  {'/Swath/iceWaterPath', 'TMI iceWaterPath(2A12)', 'float'},...
                                  {'/Swath/seaSurfaceTemperature', 'TMI seaSurfaceTemperature(2A12)', 'float'},...
                                  {'/Swath/totalPrecipitableWater', 'TMI totalPrecipitableWater(2A12)', 'float'},...
                                  {'/Swath/windSpeed', 'TMI windSpeed(2A12)', 'float'},...
                                  {'/Swath/freezingHeightIndex', 'TMI freezingHeightIndex(2A12)', 'int8'},...
                                  {'/Swath/clusterNumber', 'TMI clusterNumber(2A12)', 'int8'},...
                                  {'/Swath/clusterScale', 'TMI clusterScale(2A12)', 'float'}
                                  };
        % Write 2A12 Content
        for cindex=1:length(TMI_2A12_SDS_CONTENTS)
            tmi_2A12_path = TMI_2A12_SDS_CONTENTS{cindex}{1};
            tmi_INT_path = TMI_2A12_SDS_CONTENTS{cindex}{2};
            tmi_INT_type = TMI_2A12_SDS_CONTENTS{cindex}{3};
            write_sds(get_block_PR(tmi_2A12_file, tmi_2A12_path, TMI_Context_Range), tmi_INT_path, tmi_INT_type, cs_trmm_hdf_id);
        end
        
        status = hdfsd('end',cs_trmm_hdf_id);
        if status == -1
            error('error in endaccess to hdf file %s\n', cs_trmm_hdf_file);
        end
        

        %% WRITE VDATA OUTPUT
        % Read Geolocation Fields
        vlist = h4vsmultiread2cells(cs_file, CS_Geolocation_Fields, ...
                {'TAI_start', 'Range_to_intercept'}, 1);
        vlist = [vlist, h4vsmultiread2cells(cs_file, CS_Geolocation_Fields, ...
                           {'DEM_elevation'}, CS_Curtain_Range)];
        vlist = [vlist, h4vsmultiread2cells(cs_file, CS_Geolocation_Fields, ...
                           {'Vertical_binsize', 'Pitch_offset', 'Roll_offset'}, 1)];
        % Read Data Fields
        vlist = [vlist, h4vsmultiread2cells(cs_file, '/2B-GEOPROF/Data Fields/', ...
                           {'Data_quality', 'Data_status', 'Data_targetID', 'SurfaceHeightBin', 'SurfaceHeightBin_fraction'}, ...
                            CS_Curtain_Range)];
        h4vswrite(cs_trmm_hdf_file, vlist, 'write');
        
        % This is a dirty trick to reuse the function, since struct's name
        % is similarly to variable's name
        h4vs1write(cs_trmm_hdf_file, 'Sigma-Zero', h4vsread2mat(cs_file, '/2B-GEOPROF/Data Fields/', 'Sigma-Zero', CS_Curtain_Range), 'write');
        vlist = h4vsmultiread2cells(cs_file, '/2B-GEOPROF/Data Fields/', ...
                 {'MODIS_cloud_flag', 'MODIS_Cloud_Fraction', 'MODIS_scene_char', 'MODIS_scene_var', ...
                 'CPR_Echo_Top', 'sem_NoiseFloor', 'sem_NoiseFloorVar', 'sem_NoiseGate', ...
                 'Navigation_land_sea_flag', 'Clutter_reduction_flag'}, CS_Curtain_Range);
        h4vswrite(cs_trmm_hdf_file, vlist, 'write');
        
        h4vs1write(cs_trmm_hdf_file, 'nray:2B-GEOPROF', nray, 'write');
        h4vs1write(cs_trmm_hdf_file, 'nbin:2B-GEOPROF', nbin, 'write');
        
        vlist = h4sds1fields2cells(trmm_file, 'PR_CAL_COEF', '/pr_cal_coef/', {'transCoef', 'receptCoef'}); %TODO: missing fcifIOchar
        vlist = [vlist, h4sds1fields2cells(trmm_file, 'RAY_HEADER', '/ray_header/', ...
                                    {'rayStart', 'raySize', 'angle', 'startBinDist', 'rainThres1', 'rainThres2', ...
                                    'transAntenna', 'recvAntenna', 'onewayAlongTrack', 'onewayCrossTrack', 'eqvWavelength', ...
                                    'radarConst', 'prIntrDelay', 'rangeBinSize', 'logAveOffset', 'mainlobeEdge'})]; %TODO: missing sidelobeRange
        vlist = [vlist, h4sds1fields2cells(trmm_file, 'pr_scan_status', '/Swath/scanStatus/', ...
                                    {'missing', 'validity', 'qac', 'geoQuality', 'dataQuality', 'SCorientation', ...
                                    'acsMode', 'yawUpdateS', 'prMode', 'prStatus1', 'prStatus2', ...
                                    'FractionalGranuleNumber'})];
        vlist = [vlist, h4sds1fields2cells(trmm_file, 'pr_navigation', '/Swath/navigation/', ...
                                    {'scPosX', 'scPosY', 'scPosZ', 'scVelX', 'scVelY', 'scVelZ', ...
                                    'scLat', 'scLon', 'scAlt', 'scAttRoll', 'scAttPitch', 'scAttYaw', ...
                                    'greenHourAng'})]; %TODO 2nd from last missing SensorOrientationMatrix
        vlist = [vlist, h4sds1fields2cells(trmm_file, 'powers', '/Swath/powers/', ...
                                    {'radarTransPower', 'transPulseWidth'})];
        h4vswrite(cs_trmm_hdf_file, vlist, 'write');
        fprintf('ending exporting with status %i\n', status);
    end