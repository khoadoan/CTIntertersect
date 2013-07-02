function [ yyyy, mm, dd ] = parse_trmm_filename( trmm_file )
trmm_filename_extract_pattern = '1C21\.(\d\d)(\d\d)(\d\d)\.(\d\d\d\d\d)';
trmm_filename_extract_tokens = regexp(trmm_file, trmm_filename_extract_pattern, 'tokens');
trmm_filename_extract_tokens = trmm_filename_extract_tokens{1,1};
yyyy = str2num(sprintf('20%s', trmm_filename_extract_tokens{1}));
mm = str2num(trmm_filename_extract_tokens{2});
dd = str2num(trmm_filename_extract_tokens{3});
end

