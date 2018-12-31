function accel = get_accel_data_variable(data, meta)
%GET_ACCEL_DATA Extract the accelerometer data and assign impact-relative timestamps.
%
%  accel = get_accel_data(data)
%
%  Input:
%     data  -  Impact data in the format returned by read_impact_table_variable.
%     meta  -  Metadata returned by read_impact_table_variable.
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
%  See also READ_IMPACT_TABLE_VARIABLE.
%

%% Derived Values

% The amount of time that passes between each accelerometer sample
sampling_interval = 1 / meta.SampleRate;

% Each sample is separated by sampling_interval seconds; just need to offset
% each sample's index by the number that precede the impact to calculate
% the offset in seconds in interval mode.
if meta.CaptureMode == 1
    % The number of samples that precede the point of impact.
    presamples = meta.PreSamples;
    timestamps = (data.Index - presamples) * sampling_interval;
elseif meta.CaptureMode == 2
    timestamps = (data.Index*sampling_interval);
end
% Subset the original table and add the timestamp column.
accel = data(:, {'Impact', 'Index', 'AccelX', 'AccelY', 'AccelZ'});
accel.Timestamp = timestamps;

end
