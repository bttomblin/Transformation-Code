function accel = get_accel_data(data)
%GET_ACCEL_DATA Extract the accelerometer data and assign impact-relative timestamps.
%
%  accel = get_accel_data(data)
%
%  Input:
%     data  -  Impact data in the format returned by read_impact_table.
%
%  Output:
%     accel -  A table containing the accelerometer samples for all
%              impacts in the impact file. See Notes below.
%                 
%  Notes:
%     For each impact, the samples are in chronological order, and the
%     Timestamp column is the offset from the point of impact. Thus,
%     negative values represent time before the impact and positive
%     values represent time after the impact.
%
%  See also READ_IMPACT_TABLE.
%


%% Constants - These values cannot be derived from the data table.

% The sample rate of the accelerometer, in Hz.
accelerometer_sample_rate = 4684;

% The portion of the sample that precedes the point of impact.
presample_proportion = 0.25;


%% Derived Values

% The amount of time that passes between each accelerometer sample
sampling_interval = 1 / accelerometer_sample_rate;

% Since per-impact indices are zero-based, the number of samples
% per impact is 1 + the largest index value.
samples_per_impact = max(data.Index) + 1;

% The number of samples that precede the point of impact.
presamples = ceil(samples_per_impact * presample_proportion);

% Each sample is separated by sampling_interval seconds; just need to offset
% each sample's index by the number that precede the impact to calculate
% the offset in seconds.
timestamps = (data.Index - presamples+1) * sampling_interval;

% Subset the original table and add the timestamp column.
accel = data(:, {'Impact', 'Index', 'AccelX', 'AccelY', 'AccelZ'});
accel.Timestamp = timestamps;

end
