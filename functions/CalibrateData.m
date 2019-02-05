function CalibrateData

global impacts

%% Calibrate Data
for k = 1:length(impacts) 
    x_cal = (impacts{1,k}.RawData.AccelX - 1560)./7;
    y_cal = (impacts{1,k}.RawData.AccelY - 1560)./7;
    z_cal = (impacts{1,k}.RawData.AccelZ - 1560)./7;
    x_cal_g = impacts{1,k}.RawData.GyroX.*0.07;
    y_cal_g = impacts{1,k}.RawData.GyroY.*0.07;
    z_cal_g = impacts{1,k}.RawData.GyroZ.*0.07;
    
    impacts{1,k}.CalibratedData.Units = 's, g''s, deg/s';
    impacts{1,k}.CalibratedData.Index = impacts{1,k}.RawData.Index;
    impacts{1,k}.CalibratedData.AccelTime = impacts{1,k}.RawData.AccelTime;
    impacts{1,k}.CalibratedData.Accel = [x_cal y_cal z_cal];
    impacts{1,k}.CalibratedData.AccelRes = sqrt(sum([x_cal y_cal z_cal].^2,2));
    impacts{1,k}.CalibratedData.GyroTime = impacts{1,k}.RawData.GyroTime;
    impacts{1,k}.CalibratedData.Gyro = [x_cal_g y_cal_g z_cal_g];
    impacts{1,k}.CalibratedData.GyroRes = sqrt(sum([x_cal_g y_cal_g z_cal_g].^2,2));
end

CheckThreshold

end