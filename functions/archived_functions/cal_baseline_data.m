function [accel_cal, gyro_cal, Time_Date_Full] = cal_baseline_data(file_name, baseline_folder, fs_accel, fc_accel, fs_gyro, fc_gyro)

% fc (cutoff frequency, Hz), no filter = []
% fs (sampling rate, Hz), no filter = []
Filter(1).fs_gyro = fs_gyro;
Filter(1).fc_gyro = fc_gyro;
Filter(1).fs_accel = fs_accel;
Filter(1).fc_accel = fc_accel;

Impact_Totals = [];

Data = readtable(file_name);

% Baseline Functions (Based on Rate Table Calibration)
[Baseline_Accel,Baseline_Gyro,r_CG,r_Accel,r_Gyro] = ...
    BASELINE_AUTO_RATE_TRANS(file_name,baseline_folder);

% Calculate Accelerations, Velocities, and Time
[Time_Date_Full,Data_Accel,Data_Gyro,Data_Accel_Cal,...
    Data_Gyro_Cal,Data_Accel_Cal_Filt_Zero,...
    Data_Gyro_Cal_Filt_Zero,Linear_Resultant,...
    Rotational_Resultant,Impact_Totals] = ...
    DATA_CALC_15_RATE_FILT(Data,Baseline_Accel,...
    Baseline_Gyro,Filter,Impact_Totals);

Data_Accel_Cal.Impact = Data_Accel_Cal.Impact - 1;
Data_Gyro_Cal.Impact = Data_Gyro_Cal.Impact - 1;

accel_cal = [Data_Accel_Cal.Impact, Data_Accel_Cal.Index, Data_Accel_Cal.AccelX, Data_Accel_Cal.AccelY, Data_Accel_Cal.AccelZ, Data_Accel_Cal.Timestamp]; 
%restructure to same shape as original table with same column names
accel_cal = array2table(accel_cal, 'VariableNames', {'Impact' 'Index' 'AccelX' 'AccelY' 'AccelZ' 'Timestamp'});

gyro_cal = [Data_Gyro_Cal.Impact, Data_Gyro_Cal.Index, Data_Gyro_Cal.GyroX, Data_Gyro_Cal.GyroY, Data_Gyro_Cal.GyroZ, Data_Gyro_Cal.Timestamp]; 
%restructure to same shape as original table with same column names
gyro_cal = array2table(gyro_cal, 'VariableNames', {'Impact' 'Index' 'GyroX' 'GyroY' 'GyroZ' 'Timestamp'});

end