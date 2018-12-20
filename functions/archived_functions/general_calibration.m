function cal_table = general_calibration(data_file, folder_out, file_out, idx_real)

% This function reads accelerometer and gyroscope data downloaded from the mouthpiece
% device and uses a general calibration to convert
% accelerometer data to g and gyroscope data to deg/s. 
% 
% INPUTS: data_file is a file containing data in the same format in which it is
% downloaded from the device.
% 
% OUTPUTS: accel_cal is a table in the same format as the input data_file,
% but with the accelerometer readings converted to g.

[accel, gyro] = read_accel_and_gyro(data_file);

% eliminate filler data
accel = accel(ismember(accel.Impact+1, idx_real),:);
gyro = gyro(ismember(gyro.Impact+1, idx_real),:);

%use calibration values to convert accel readings
x_cal = (accel.AccelX - 1560)./7;
y_cal = (accel.AccelY - 1560)./7;
z_cal = (accel.AccelZ - 1560)./7;
accel_cal = [accel.Impact, accel.Index, x_cal, y_cal, z_cal, accel.Timestamp]; 
%use calibration values to convert gyro readings
x_cal_g = gyro.GyroX.*0.07;
y_cal_g = gyro.GyroY.*0.07;
z_cal_g = gyro.GyroZ.*0.07;
gyro_cal = [gyro.Impact, gyro.Index, x_cal_g, y_cal_g, z_cal_g, gyro.Timestamp];
%restructure to same shape as original table with same column names
accel_cal = array2table(accel_cal, 'VariableNames', {'Impact' 'Index' 'AccelX' 'AccelY' 'AccelZ' 'Timestamp'});
gyro_cal = array2table(gyro_cal, 'VariableNames', {'Impact' 'Index' 'GyroX' 'GyroY' 'GyroZ' 'Timestamp'});
%create table of combined accel and gyro values and output in desired
%format
cal_table = table(accel_cal.Impact, accel_cal.Index, accel_cal.AccelX, accel_cal.AccelY, accel_cal.AccelZ, accel_cal.Timestamp,...
    gyro_cal.GyroX, gyro_cal.GyroY, gyro_cal.GyroZ, gyro_cal.Timestamp, ...
    'VariableNames', {'Impact', 'Index', 'AccelX', 'AccelY', 'AccelZ', 'AccelTime', 'GyroX', 'GyroY', 'GyroZ', 'GyroTime'});


%check if optional input parameters used and save to file, if so.
if nargin > 2
    if nargin < 3
        error('Error: specify filename')
    end
    save_file_name = fullfile(folder_out, file_out);
    if ~isdir(folder_out)
        error('Error: The folder does not exist.'); 
    end
    writetable(cal_table, save_file_name); %write oombined table to csv using new filename
end
end
