function gyro = get_gyro_data_variable(data)
%GET_GYRO_DATA Extract the gyroscope data and assign impact-relative timestamps.
%
%  gyro = get_gyro_data(data)
%
%  Input:
%     data  -  Impact data in the format returned by read_impact_table.
%     meta  -  Metadata returned by read_impact_table_variable.
%
%  Output:
%     gyro     -  A table containing the gyroscope samples for all
%                 impacts in the impact file. See Notes below.
%                 
%  Notes:
%     For each impact, the samples are in chronological order, and the
%     Timestamp column is the offset from the point of impact. Thus,
%     negative values represent time before the impact and positive
%     values represent time after the impact.
%
%  See also READ_IMPACT_TABLE.
%


% The number of clock ticks per second on the CC2640.
ticks_per_second = 65536;

% The records in the original data table are in chronological order for
% the accelerometer samples. The Timestamp column corresponds to the
% timing of the gyroscope sample on each row. The Timestamp values are
% the number of ticks before or after the point of impact that the sample
% was recorded. So to put the gyroscope data in chronological order, we
% just reorder the table by timestamp, taking care to first sort by impact
% to keep the samples of each impact independent.
data = sortrows(data, {'Impact', 'Timestamp'});

%remove zero data that appear when gyro can't keep up with accel sample
%rate
data = data(data.Timestamp ~= 0, :);

% Then, just convert the number of ticks before/after the sample to the
% number of seconds before/after the sample.
data.Timestamp = data.Timestamp / ticks_per_second;

% Finally, subset the original table.
gyro = data(:, {'Impact', 'Index', 'GyroX', 'GyroY', 'GyroZ', 'Timestamp'});

end
