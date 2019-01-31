function CalculatePeaks

global impacts 

for i = 1:length(impacts)
    
    if(isfield(impacts{1,i},'TransformedData'))
        data = impacts{1,i}.TransformedData;

        [~,ix] = max(abs(data.Accel(:,1)));
        peakX = data.Accel(ix,1);
        [~,ix] = max(abs(data.Accel(:,2)));
        peakY = data.Accel(ix,2);
        [~,ix] = max(abs(data.Accel(:,3)));
        peakZ = data.Accel(ix,3);

        impacts{1,i}.PeakValues.Units = 'g''s, rad/s, rad/s^2';
        impacts{1,i}.PeakValues.LinAccX = peakX;
        impacts{1,i}.PeakValues.LinAccY = peakY;
        impacts{1,i}.PeakValues.LinAccZ = peakZ;
        impacts{1,i}.PeakValues.LinAcc = max(data.AccelRes);

        [~,ix] = max(abs(data.Gyro(:,1)));
        peakX = data.Gyro(ix,1);
        [~,ix] = max(abs(data.Gyro(:,2)));
        peakY = data.Gyro(ix,2);
        [~,ix] = max(abs(data.Gyro(:,3)));
        peakZ = data.Gyro(ix,3);

        impacts{1,i}.PeakValues.RotVelX = peakX;
        impacts{1,i}.PeakValues.RotVelY = peakY;
        impacts{1,i}.PeakValues.RotVelZ = peakZ;
        impacts{1,i}.PeakValues.RotVel = max(data.GyroRes);

        [~,ix] = max(abs(data.AngAcc(:,1)));
        peakX = data.AngAcc(ix,1);
        [~,ix] = max(abs(data.AngAcc(:,2)));
        peakY = data.AngAcc(ix,2);
        [~,ix] = max(abs(data.AngAcc(:,3)));
        peakZ = data.AngAcc(ix,3);

        impacts{1,i}.PeakValues.RotAccX = peakX;
        impacts{1,i}.PeakValues.RotAccY = peakY;
        impacts{1,i}.PeakValues.RotAccZ = peakZ;
        impacts{1,i}.PeakValues.RotAcc = max(data.AngAccRes);
    end
end

end