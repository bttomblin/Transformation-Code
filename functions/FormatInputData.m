function FormatInputData

global DataFolder devices impacts 
voltage_threshold = 3.27;

files = dir(fullfile(DataFolder,'*.csv'));
impacts = [];

for i = 1:length(files)
    currentFile = fullfile(DataFolder,files(i).name);
    ind = strfind(files(i).name,' ');
    device{i} = files(i).name(1:ind(1)-1);

    [accel, gyro] = read_accel_and_gyro(currentFile);
    rawTimestamp = readtable(currentFile);
    inds = [1:283:length(rawTimestamp.Index)];
    timestamps = rawTimestamp.Timestamp(inds);
    
    voltage = getvoltage(currentFile);
    idx_dead = find(voltage < voltage_threshold);
    if isempty(idx_dead) == 1
        idx_real = [1:1:length(voltage)];
    else
        idx_real = 1:idx_dead(1)-1;
    end
    
    % eliminate filler data
    accel = accel(ismember(accel.Impact+1, idx_real),:);
    gyro = gyro(ismember(gyro.Impact+1, idx_real),:);
    timestamps = timestamps(idx_real);
    
    rawDataAll = table(accel.Impact, accel.Index, accel.AccelX, accel.AccelY, accel.AccelZ, accel.Timestamp,...
        gyro.GyroX, gyro.GyroY, gyro.GyroZ, gyro.Timestamp, ...
        'VariableNames', {'Impact', 'Index', 'AccelX', 'AccelY', 'AccelZ', 'AccelTime', 'GyroX', 'GyroY', 'GyroZ', 'GyroTime'});
    
    % Converts Epoch datetime to EST datetime
    time_reference = datenum('1970', 'yyyy'); 
    time_date_temp = (time_reference+(timestamps-14400)./8.64e4);
    impact_time = datestr(time_date_temp, 'yyyymmdd HH:MM:SS.FFF');
    for imp = 1:size(impact_time,1)
       temp = impact_time(imp,:);
       impactDates{imp} = temp(1:8);
       impactTimes{imp} = temp(10:end);
    end

    for j = 0:max(rawDataAll.Impact)
        % extract accel and gyro data
        wf_data = rawDataAll(rawDataAll.Impact==j, :); 
        
        impacts_temp{1,j+1}.Info.MouthpieceID = device{i};
        impacts_temp{1,j+1}.Info.ImpactDate = impactDates{j+1};
        impacts_temp{1,j+1}.Info.ImpactTime = impactTimes{j+1};
        impacts_temp{1,j+1}.Info.ImpactIndex = wf_data.Impact(1);
        impacts_temp{1,j+1}.RawData.Index = wf_data.Index;
        impacts_temp{1,j+1}.RawData.AccelTime = wf_data.AccelTime;
        impacts_temp{1,j+1}.RawData.AccelX = wf_data.AccelX;
        impacts_temp{1,j+1}.RawData.AccelY = wf_data.AccelY;
        impacts_temp{1,j+1}.RawData.AccelZ = wf_data.AccelZ;
        impacts_temp{1,j+1}.RawData.GyroTime = wf_data.GyroTime;
        impacts_temp{1,j+1}.RawData.GyroX = wf_data.GyroX;
        impacts_temp{1,j+1}.RawData.GyroY = wf_data.GyroY;
        impacts_temp{1,j+1}.RawData.GyroZ = wf_data.GyroZ;
    end
    impacts = horzcat(impacts,impacts_temp);
    clear('impacts_temp')
end

devices = unique(device);
end