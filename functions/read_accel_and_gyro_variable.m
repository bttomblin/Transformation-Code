function [accel, gyro, meta] = read_accel_and_gyro_variable(filename)
%READ_ACCEL_AND_GYRO Loads impact data and process the accelerometer and gyroscope samples.
%
%  [accel, gyro] = read_accel_and_gyro(filename)
%
%  Input:
%     filename -  The path to a .csv file containing impact data.
%
%  Output:
%     accel    -  A table containing the accelerometer samples for all
%                 impacts in the impact file. See Notes below.
%     gyro     -  A table containing the gyroscope samples for all
%                 impacts in the impact file. See Notes below.
%                 
%  Notes:
%     In both the accel and gyro tables, for each impact, the samples
%     are in chronological order, and the Timestamp column is the
%     offset from the point of impact. Thus, negative values represent
%     time before the impact and positive values represent time after
%     the impact.
%
%  See also READ_IMPACT_TABLE, GET_ACCEL_DATA, GET_GYRO_DATA.
%


[data, meta] = read_impact_table_variable(filename);
accel = get_accel_data_variable(data, meta);
gyro = get_gyro_data_variable(data);

end
