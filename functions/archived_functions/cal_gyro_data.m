function gyro_cal = cal_gyro_data(cal_folder, data_file)
%This function reads gyroscope data downloaded from the mouthpiece
%device and uses device-specific calibration values to convert
%data to deg/s. 
%
%INPUTS: cal_folder - path to folder containing calibration values for device.
%'X:\02_projects\mouthpiece\Rate Table Calibration\Device Data\MP0067 - Calibration Data'
%The filename in that folder containing gyro calibration values should be
%'Calibration Equations Gyro.csv', which is the file output by
%'rate_table_calibration_gyro.m'.
%Values must be in formtat output by 'rate_table_calibration_gyro.m':
%
%          Slope     Offset
%          ______    ______
% 
%     X    6.6059    1555.1
%     Y    6.6803      1554
%     Z    7.0548    1567.6
%
%data_file is a file containing data in the same format in which it is
%downloaded from the device.
%
%OUTPUTS: gyro_cal is a table in the same format as the input data_file,
%but with the accelerometer readings converted to deg/s.

%open file in cal_folder containing gyro calibration values.
cal_file = fullfile(cal_folder, 'Calibration Equations Gyro.csv');
%read in calibration data from file generated in calibration code
%row names correspond to axis, column names correspond to slope or offset
f = readtable(cal_file, 'ReadRowNames', 1); 
[~, gyro] = read_accel_and_gyro(data_file);
%use calibration values to convert gyro readings
x_cal = (gyro.GyroX - f.Offset('X'))./ f.Slope('X');
y_cal = (gyro.GyroY - f.Offset('Y'))./ f.Slope('Y');
z_cal = (gyro.GyroZ - f.Offset('Z'))./ f.Slope('Z');

gyro_cal = [gyro.Impact, gyro.Index, x_cal, y_cal, z_cal, gyro.Timestamp]; 
%restructure to same shape as original table with same column names
gyro_cal = array2table(gyro_cal, 'VariableNames', {'Impact' 'Index' 'GyroX' 'GyroY' 'GyroZ' 'Timestamp'});

end
