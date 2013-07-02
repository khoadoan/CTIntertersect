mine = 'C:\school\matlab\data\CS_TR\2007204011308_04C_034S_167W_10906_06563_CS_55176_TR.hdf';
his = 'C:\school\matlab\data\2007204011240_04C_34S_166W_01604_06563_CS_55176_TR_v03.hdf';

myinfo = hdfinfo(mine);
hisinfo = hdfinfo(his);

mysds = myinfo.SDS;
hissds = hisinfo.SDS;

for i = 1:length(mysds)
    fprintf ('%i. checking field %s: ', i, mysds(i).Name);
    myfdata = hdfread(mysds(i).Filename, mysds(i).Name);
    hisfdata = hdfread(hissds(i).Filename, mysds(i).Name);
    % First verify the dimensions
    fprintf(' dimensions...');
    dcheck = (size(myfdata) == size(hisfdata));
    if sum(dcheck) < length(dcheck)
        fprintf('FAILED');
    else
        fprintf('OK');
    end
    
    % Second verify content
    fprintf(' content...');
    ccheck = logical(myfdata ~= hisfdata);
    if sum(sum(sum(ccheck))) > 0
        fprintf('FAILED');
    else
        fprintf('OK');
    end
    fprintf(' \tDONE\n');
end

i = 14;
myscans = hdfread(mysds(i).Filename, mysds(i).Name);
hisscans = hdfread(hissds(i).Filename, mysds(i).Name);
i = 15;
myrays = hdfread(mysds(i).Filename, mysds(i).Name);
hisrays = hdfread(hissds(i).Filename, mysds(i).Name);

indices = [myscans', hisscans', myrays', hisrays'];

[cs_lat, cs_lon, cs_time] = read_cs('C:\school\matlab\data\CS\', '2007204003308_06563_CS_2B-GEOPROF_GRANULE_P_R04_E02.hdf', 204, 2007);
[tr_lat, tr_lon, tr_time] = read_trmm_v6('C:\school\matlab\data\v6\1C21\', '1C21.070723.55176.6.hdf', 204, 2007);

plot(cs_lon, cs_lat, 'r');
hold on;
plot(tr_lon, tr_lat);

i1 = intersections(1);
curtain = i1.curtain_indexes;
plot(cs_lon(curtain(:, 1)), cs_lat(curtain(:, 1)), 'o', 'color', 'r');
plot(tr_lon(unique(curtain(:,2)), :), tr_lat(unique(curtain(:,2)), :), '.')

