function offset = mp_zero_offset_gyro(data)
    %%removes baseline offset from MP data.
    %operates on data column-wise to take an average of the first 
    %8 data points and subtracts the column's average from from all data in that column.
    off = data(5, :);
    offset = zeros(size(data));
    for i = 1:length(off)
        offset(:,i) = data(:,i) - off(i);
    end
    offset(1:4,:) = zeros(4,size(data,2));
end
