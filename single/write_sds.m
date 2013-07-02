function [ status ] = write_sds( X, sds_name, sds_type, hdf_id )
% ndims(X), size(fliplr(size(X))), zeros(1:ndims(X))
X = permute(X, ndims(X):-1:1);
sds_id = hdfsd('create',hdf_id,sds_name, sds_type, ndims(X),fliplr(size(X)));
status = hdfsd('writedata',sds_id, zeros(1, ndims(X)), [], ...
    fliplr(size(X)), X);
status = hdfsd('end', sds_id);
end

