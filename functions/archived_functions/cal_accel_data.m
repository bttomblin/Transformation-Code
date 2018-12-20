function accel_cal = cal_accel_data(cal_folder, data_file)
% This function reads accelerometer data downloaded from the mouthpiece
% device and uses device-specific calibration values to convert
% accelerometer data to g. 
% 
% INPUTS: cal_folder - path to folder containing calibration values for device.
% 'X:\02_projects\mouthpiece\Rate Table Calibration\Device Data\MP0067 - Calibration Data'
% The filename in that folder containing accel calibration values should be
% 'Calibration Equations Accel.csv', which is the file output by
% 'rate_table_calibration_accel.m'.
% Values must be in formtat output by 'rate_table_calibration_accel.m':
% 
%          Slope     Offset
%          ______    ______
% 
%     X    6.6059    1555.1
%     Y    6.6803      1554
%     Z    7.0548    1567.6
% 
% data_file is a file containing data in the same format in which it is
% downloaded from the device.
% 
% OUTPUTS: accel_cal is a table in the same format as the input data_file,
% but with the accelerometer readings converted to g.
   
        
%open file in cal_folder containing gyro calibration values.
cal_file = fullfile(cal_folder, 'Calibration Equations Accel.csv');
%read in calibration data from file generated in calibration code
%row names correspond to axis, column names correspond to slope or offset
f = readtable(cal_file, 'ReadRowNames', 1); 
[accel, ~] = read_accel_and_gyro(data_file);
%use calibration values to convert accel readings
x_cal = (accel.AccelX - f.Offset('X'))./ f.Slope('X');
y_cal = (accel.AccelY - f.Offset('Y'))./ f.Slope('Y');
z_cal = (accel.AccelZ - f.Offset('Z'))./ f.Slope('Z');
% x_cal = (accel_array(:, 3) - 1555)./6.57; %these values currently specific to MP0061 1555, 1563, 1557
% y_cal = (accel_array(:, 4) - 1563)./6.87;
% z_cal = (accel_array(:, 5) - 1555)./7.23; %check z axis of 61 - consistently 2.5g off w/ offset of 1545
accel_cal = [accel.Impact, accel.Index, x_cal, y_cal, z_cal, accel.Timestamp]; 
%restructure to same shape as original table with same column names
accel_cal = array2table(accel_cal, 'VariableNames', {'Impact' 'Index' 'AccelX' 'AccelY' 'AccelZ' 'Timestamp'});

end
