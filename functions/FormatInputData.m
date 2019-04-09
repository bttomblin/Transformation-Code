function FormatInputData

codeVersion = 'v1';

global DataFolder devices impacts numMetaDataLines
voltage_threshold = 3.27;

files = dir(fullfile(DataFolder,'*.csv'));
impacts = [];

for i = 1:length(files)
    currentFile = fullfile(DataFolder,files(i).name);
    ind = strfind(files(i).name,' ');
    device{i} = files(i).name(1:ind(1)-1);
    
    % determine whether MP output 1 or 2 lines of meta data
    numMetaDataLines = determineFirmwareVersion(currentFile);
    
%     if numMetaDataLines == 1   
%         [accel, gyro] = read_accel_and_gyro(currentFile);
%         sampleRate = 4684;
%     else
%         [accel, gyro, meta] = read_accel_and_gyro_variable(currentFile);
%         sampleRate = meta.SampleRate;
%     end
%     rawTimestamp = readtable(currentFile);
%     temp=rawTimestamp.Timestamp;
%     inds = find(temp>1e9);
%     timestamps = rawTimestamp.Timestamp(inds);
    
    if numMetaDataLines == 1   
        [accel, gyro] = read_accel_and_gyro(currentFile);
        sampleRate = 4684;
        raw = readtable(currentFile);
        inds = (1:283:length(raw.Index));
        timestamps = raw.Timestamp(inds);
        voltage = round(raw.AccelX(inds)./256,3);
    else
        [accel, gyro, meta] = read_accel_and_gyro_variable(currentFile);
        sampleRate = meta.SampleRate;
        raw = readtable(currentFile);
    if meta.CaptureMode == 1
        samples_per_impact = raw.AccelZ(1)+2+raw.AccelY(1);
        inds = (1:samples_per_impact:length(raw.Index));
        timestamps = raw.Timestamp(inds);
        voltage = round(raw.AccelX(inds)./256,3);
    else
        samples_per_impact = raw.AccelZ(1)+2;
        inds = (1:samples_per_impact:length(raw.Index));
        timestamps = raw.Timestamp(inds);
        voltage = round(raw.AccelX(inds)./256,3);
    end
    end

%     voltage = getvoltage(currentFile);
%     idx_real = [1:1:length(voltage)];
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
    
    if(~isempty(accel))
        rawDataAll = table(accel.Impact, accel.Index, accel.AccelX, accel.AccelY, accel.AccelZ, accel.Timestamp,...
            gyro.GyroX, gyro.GyroY, gyro.GyroZ, gyro.Timestamp, ...
            'VariableNames', {'Impact', 'Index', 'AccelX', 'AccelY', 'AccelZ', 'AccelTime', 'GyroX', 'GyroY', 'GyroZ', 'GyroTime'});

        % Converts Epoch datetime to EST datetime
        time_reference = datenum('1970', 'yyyy'); 
%         time_date_temp = (time_reference+(timestamps-14400)./8.64e4);
        for q = 1:length(timestamps) 
        if timestamps(q,1) > 1520751600 && timestamps(q,1) < 1541314800 || timestamps(q,1) > 1552201200 && timestamps(q,1) < 1572764400 %DST for 2018 and 2019
            time_date_temp(q,1) = (time_reference+(timestamps(q,1)-14400)./8.64e4); % 14400 for EST
        else
            time_date_temp(q,1) = (time_reference+(timestamps(q,1)-14400-3600)./8.64e4); % 14400 for EST, 3600 for non-DST
        end
        end

        impact_time = datestr(time_date_temp, 'yyyymmdd HH:MM:SS.FFF');
        for imp = 1:size(impact_time,1)
           temp = impact_time(imp,:);
           impactDates{imp} = temp(1:8);
           impactTimes{imp} = temp(10:end);
        end

        impactInds = unique(rawDataAll.Impact);
%         for j = 0:max(rawDataAll.Impact)

        for j = 1:length(impactInds)
            % extract accel and gyro data
            wf_data = rawDataAll(rawDataAll.Impact==impactInds(j), :); 

            impacts_temp{1,j}.Info.MouthpieceID = device{i};
            impacts_temp{1,j}.Info.AccelSampleRate = sampleRate;
            impacts_temp{1,j}.Info.ImpactDate = impactDates{j};
            impacts_temp{1,j}.Info.ImpactTime = impactTimes{j};
            impacts_temp{1,j}.Info.ImpactIndex = wf_data.Impact(1);
            impacts_temp{1,j}.Info.TransformCodeVersion = codeVersion;
            impacts_temp{1,j}.RawData.Index = wf_data.Index;
            impacts_temp{1,j}.RawData.AccelTime = wf_data.AccelTime;
            impacts_temp{1,j}.RawData.AccelX = wf_data.AccelX;
            impacts_temp{1,j}.RawData.AccelY = wf_data.AccelY;
            impacts_temp{1,j}.RawData.AccelZ = wf_data.AccelZ;
            impacts_temp{1,j}.RawData.GyroTime = wf_data.GyroTime;
            impacts_temp{1,j}.RawData.GyroX = wf_data.GyroX;
            impacts_temp{1,j}.RawData.GyroY = wf_data.GyroY;
            impacts_temp{1,j}.RawData.GyroZ = wf_data.GyroZ;
        end
        impacts = horzcat(impacts,impacts_temp);
        clear('impacts_temp')
    end
end

devices = unique(device);
end