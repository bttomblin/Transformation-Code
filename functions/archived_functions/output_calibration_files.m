function cal_table = output_calibration_files(accel, gyro, folder, filename)
%This function takes calibrated accel and gyroscope data tables (output
%from cal_accel_data and cal_gyro_data functions), combines them, and
%writes to a single .csv file that can be input to transformation
%functions.
%
%The inputs accel and gyro are calibrated accel and gyroscope data tables
%(from cal_accel_data and cal_gyro_data functions).
%
%The optional inputs folder and filename specify the folder and filename
%that the output table should be saved to. If they are not specified, the
%function will output cal_table but not save it to a file.
%Example of using optional inputs to save file: 
%output_calibration_files(accel, gyro, 'X:\02_projects\mouthpiece\MP0061_Ottawa_Data', 'output_test.csv');
%
%It outputs a table, cal_table, that has the following columns names in
%this order: Impact, Index, AccelX, AccelY, AccelZ, AccelTime, GyroX,
%GyroY, GyroZ, GyroTime.
%
%Impact is the impact number, ranging from zero to the number of impacts
%captured - 1 Index corresponds to the accelerometer sample number. The
%gyroscope index is not included, as the gyroscope samples were re-ordered
%into chronological order, making the indices out of order (see
%get_gyro_data.m).
%
%Accel/Gyro X, Y, Z are calibrated axis readings.
%
%AccelTime is the timepoint accelerometer readings were captured in seconds
%(see get_accel_data.m), and GyroTime is gyroscope reading timestamp
%converted to seconds. Negative times are samples recorded before the
%impact threshold was crossed.

cal_table = table(accel.Impact, accel.Index, accel.AccelX, accel.AccelY, accel.AccelZ, accel.Timestamp,...
    gyro.GyroX, gyro.GyroY, gyro.GyroZ, gyro.Timestamp, ...
    'VariableNames', {'Impact', 'Index', 'AccelX', 'AccelY', 'AccelZ', 'AccelTime', 'GyroX', 'GyroY', 'GyroZ', 'GyroTime'});

%check if optional input parameters used and save to file, if so.
if nargin > 2
    if nargin < 4
        error('Error: specify filename')
    end
    save_file_name = fullfile(folder, filename);
    if ~isdir(folder)
        error('Error: The folder does not exist.'); 
    end
    writetable(cal_table, save_file_name); %write oombined table to csv using new filename
end
end