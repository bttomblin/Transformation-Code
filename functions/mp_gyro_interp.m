function gyro_resampled = mp_gyro_interp(gyro_time, data, accel_time)
%%Interpolates gyroscope data to find gyroscope reading at accelerometer
%timepoints with a linear 1D interpolation.
%Needed because gyro and accel use different sampling rates.
%DATA should contain columns of gyroscope data to be interpolated. 
%GYRO_TIME is a column vector of gyroscope timestamps.
%ACCEL_TIME is a column vector of accelerometer timestamps. 
gyro_resampled = zeros(size(accel_time));    
for d = 1:size(data,2)
    gyro_resampled(:,d) = interp1(gyro_time,data(:,d),accel_time, 'linear', 'extrap');
end
end