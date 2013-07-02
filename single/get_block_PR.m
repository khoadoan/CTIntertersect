function [ sds_data_block ] = get_block_PR( pr_file, sds_name,  index_range)
    sds_data = hdfread(pr_file, sds_name);
    sds_data_block = sds_data(index_range, :, :);
end

