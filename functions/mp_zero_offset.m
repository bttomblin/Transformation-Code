function offset = mp_zero_offset(data)
    %%removes baseline offset from MP data.
    %operates on data column-wise to take an average of the first 
    %8 data points and subtracts the column's average from from all data in that column.
    off = mean(data(1:8, :));
    offset = zeros(size(data));
    for i = 1:length(off)
        offset(:,i) = data(:,i) - off(i);
    end
end
