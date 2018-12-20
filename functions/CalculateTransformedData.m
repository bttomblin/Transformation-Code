function CalculateTransformedData

global DataFolder defaultCalibration estimatedOrientation sport rawFolder baselineFolder calFolder devices transformationInfo tFolder impactTimes impacts

%% defining filtering characteristics
% define filtering characteristics
a_cfc = 1000; % use w/ VT filtering function (SAE J211 4 pole butter LPF)
a_fs = 4684; % accel sample rate (Hz)
g_cfc = 155; % use w/ VT filtering function
g_fs = 4684; % gyro sample rate (Hz), halved when remove duplicates, 4684 when interpolate before filter 


for k = 1:length(impacts)
   
    % transformation info
    r_cg = impacts{1,k}.Info.Transformation.ProjectionVector;
    r_accel = impacts{1,k}.Info.Transformation.RotationMatrix_Accel;
    r_gyro = impacts{1,k}.Info.Transformation.RotationMatrix_Gyro;
   
    wf_accel = impacts{1,k}.CalibratedData.Accel;
    wf_gyro = impacts{1,k}.CalibratedData.Gyro.*(pi/180);  % convert to rad/s
    accel_time = round(impacts{1,k}.CalibratedData.AccelTime, 5);  % round timestamps to remove errors caused by precision during interpolation
    gyro_time = round(impacts{1,k}.CalibratedData.GyroTime, 5);
    
    % remove duplicate gyroscope data
    [new_gyro_x, new_gyro_y, new_gyro_z, new_time_x, new_time_y, new_time_z] = mp_remove_duplicates(wf_gyro, gyro_time);
    
    % in interp1.m, all of the query values (accel_time) must be <= the last value of X (new_time_X), or else NaN is returned. 
        if(accel_time(end) > new_time_x(end))
            new_time_x(end) = accel_time(end);
        end
        if(accel_time(end) > new_time_y(end))
            new_time_y(end) = accel_time(end);
        end
        if(accel_time(end) > new_time_z(end))
            new_time_z(end) = accel_time(end);
        end

        % interpolate
        g_interp_x = mp_gyro_interp(new_time_x, new_gyro_x, accel_time);
        g_interp_y = mp_gyro_interp(new_time_y, new_gyro_y, accel_time);
        g_interp_z = mp_gyro_interp(new_time_z, new_gyro_z, accel_time);

        % filter data
        g_filt_x = j211filtfilt(g_cfc, g_fs, g_interp_x);
        g_filt_y = j211filtfilt(g_cfc, g_fs, g_interp_y);
        g_filt_z = j211filtfilt(g_cfc, g_fs, g_interp_z);
        a_filt = j211filtfilt(a_cfc, a_fs, wf_accel); 
        
        impacts{1,k}.FilteredData.Units = 's, g''s, rad/s';
        impacts{1,k}.FilteredData.Time = accel_time;
        impacts{1,k}.FilteredData.Accel = a_filt;
        impacts{1,k}.FilteredData.AccelRes = sqrt(sum(a_filt.^2,2));
        impacts{1,k}.FilteredData.Gyro = [g_filt_x g_filt_y g_filt_z];
        impacts{1,k}.FilteredData.GyroRes = sqrt(sum([g_filt_x g_filt_y g_filt_z].^2,2));
        
        % zero offset
        a_zero = mp_zero_offset(a_filt);
        g_zero_x = mp_zero_offset(g_filt_x);
        g_zero_y = mp_zero_offset(g_filt_y);
        g_zero_z = mp_zero_offset(g_filt_z);
        g_zero = [g_zero_x, g_zero_y, g_zero_z];
        
        impacts{1,k}.ZeroOffsetData.Units = 's, g''s, rad/s';
        impacts{1,k}.ZeroOffsetData.Time = accel_time;
        impacts{1,k}.ZeroOffsetData.Accel = a_zero;
        impacts{1,k}.ZeroOffsetData.AccelRes = sqrt(sum(a_zero.^2,2));
        impacts{1,k}.ZeroOffsetData.Gyro = [g_zero_x g_zero_y g_zero_z];
        impacts{1,k}.ZeroOffsetData.GyroRes = sqrt(sum([g_zero_x g_zero_y g_zero_z].^2,2));

        % rotate
        a_rotated = mp_rotation_accel(r_accel, a_zero);
        g_rotated = mp_rotation_gyro(r_gyro, g_zero);
    
        impacts{1,k}.RotatedData.Units = 's, g''s, rad/s';
        impacts{1,k}.RotatedData.Time = accel_time;
        impacts{1,k}.RotatedData.Accel = a_rotated;
        impacts{1,k}.RotatedData.AccelRes = sqrt(sum(a_rotated.^2,2));
        impacts{1,k}.RotatedData.Gyro = g_rotated;
        impacts{1,k}.RotatedData.GyroRes = sqrt(sum(g_rotated.^2,2));
        
        % calc rotational accel
        rot_acc = mp_angular_accel(accel_time, g_rotated);
        
        impacts{1,k}.RotatedData.AngAcc = rot_acc;
        impacts{1,k}.RotatedData.AngAccRes = sqrt(sum(rot_acc.^2,2));

        % transform
        a_trans = mp_transform(r_cg, a_rotated, g_rotated, rot_acc);
        a_trans = [a_trans(:,1), a_trans(:,2), a_trans(:,3)];
        
        impacts{1,k}.TransformedData.Units = 's, g''s, rad/s';
        impacts{1,k}.TransformedData.Time = accel_time;
        impacts{1,k}.TransformedData.Accel = a_trans;
        impacts{1,k}.TransformedData.AccelRes = sqrt(sum(a_trans.^2,2));
        impacts{1,k}.TransformedData.Gyro = g_rotated;
        impacts{1,k}.TransformedData.GyroRes = sqrt(sum(g_rotated.^2,2));
        impacts{1,k}.TransformedData.AngAcc = rot_acc;
        impacts{1,k}.TransformedData.AngAccRes = sqrt(sum(rot_acc.^2,2));
    
end

save(fullfile(DataFolder,'00_transformedData.mat'),'impacts')

end

