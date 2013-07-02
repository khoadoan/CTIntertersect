function [ ] = h4vs1write( hfile, vname, vdata, access)
% create a new hdf file
file_id = hdfh('open', hfile, access, 0);
if file_id == -1
  error('HDF hopen failed');
end

% initialize the V interface
status = hdfv('start',file_id);
if status == -1
  error('HDF vstart failed');
end

% ------------------
% create a new vdata
% ------------------
vclass = 'struct array';
access = 'w';
vdata_ref = -1; % flag to create
vdata_id = hdfvs('attach', file_id, vdata_ref, access);
if vdata_id == -1
  error('HDF vsattach failed');
end
% give it a name and class
status = hdfvs('setname', vdata_id, vname);
if status == -1
  error('HDF vssetname failed');
end

status = hdfvs('setclass', vdata_id, vclass);
if status == -1
  error('HDF vssetclass failed');
end

% -----------------------------------------------------
% get structure field names and define the vdata fields
% -----------------------------------------------------
% find type and size of fields the first record
ftype = class(vdata);
ftype = htype(ftype);

[fsize, nrec] = size(vdata);

status = hdfvs('fdefine', vdata_id, vname, ftype, fsize);
if status == -1
error('HDF vsfdefine failed')
end

status = hdfvs('setfields', vdata_id, vname);
if status == -1
  error('HDF vssetfields failed')
end

% ----------------
% write the vdata
% ----------------
status = hdfvs('write', vdata_id, {vdata});
if status == -1
  error('HDF vswrite failed')
end

% detach vdata_id
status = hdfvs('detach', vdata_id);
if status == -1
  error('HDF vsdetach failed')
end

% end vgroup interface access
status = hdfv('end',file_id);
if status == -1
  error('HDF vend failed')
end

% close the HDF file
status = hdfh('close',file_id);
if status == -1
  error('HDF hclose failed')
end
end

