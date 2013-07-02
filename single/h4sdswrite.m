function [ status ] = h4sdswrite( sdsData, sdsName, sdsType, hdfid )
%
sdsid = hdfsd('create', hdfid, sdsName, sdsType, ndims(sdsData),fliplr(size(sdsData)));
status = hdfsd('writedata',sdsid, zeros(1, ndims(sdsData)), [], ...
    fliplr(size(sdsData)), sdsData);
if status == -1
    error('error writing %s of type %s\n', sdsName, sdsType);
end
status = hdfsd('endaccess',sdsid);
end

