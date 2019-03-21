function [Post_Process_Temp] = PP_1Meta(Data,Title_initial,Post_Process_Temp,Filter)

if rem(height(Data),283) ~= 0
    errornumber = height(Data)/283;
    fprintf('\nERROR: %s has samples for only %.2f impacts. Excluded from quality check. Redownload data.\n',Title_initial,errornumber);
else
%% Get name of MP
    ind_Space = strfind(Title_initial," ");
    ind_MP = strfind(Title_initial,"MP");
        MP_name = str2double(Title_initial(ind_MP(1,1)+2:ind_Space(1,1)-1));

%% Create Impact Index
    % This value is hard-coded because it can't be derived from the data.
    % Alternatively, this function could be refactored to provide the
    % samples/impact as an argument.
        IMP_samples_per_impact = 283;
        
    % Add a column with each record's impact number, and renumber the
    % indices so that each impact's indices count up from zero.
        Data.Impact = floor(Data.Index/IMP_samples_per_impact)+1;
        Data.Index = mod(Data.Index,IMP_samples_per_impact);

    % Separate Date timestamps.
        Metadata = Data(Data.Index<1,:);
            Date_Time = Metadata.Timestamp;

%% Find Voltages
        Metadata_Voltage = Metadata.AccelX;
    
    % Calculate voltage
        voltage = Metadata_Voltage./256;
        Voltage_Min = round(min(voltage),3);
           
%% prepare Data file for rest of formatting
    % Drop the first record of each impact; don't need the
    % metadata for this example.
        Data = Data(Data.Index>0, :);
    % Renumber the indices so they're 0-based
        Data.Index = Data.Index - 1;
        
%% Separate Accel
    Data_Accel = Data(:,{'Impact','Index','AccelX','AccelY','AccelZ'});
    Events = max(Data_Accel.Impact);

%% Convert Accel Timesteps
    % Accel
        % Constants - These values cannot be derived from the data table.
            % The sample rate of the accelerometer, in Hz.
                accelerometer_sample_rate = 4684;

            % The portion of the sample that precedes the point of impact.
                presample_proportion = 0.25;
                
        % Derived Values
            % The amount of time that passes between each accelerometer sample
                sampling_interval = 1 / accelerometer_sample_rate;

            % Since per-impact indices are zero-based, the number of samples
            % per impact is 1 + the largest index value.
                ACC_samples_per_impact = max(Data_Accel.Index)+1;

            % The number of samples that precede the point of impact.
                presamples = ceil(ACC_samples_per_impact*presample_proportion);

            % Each sample is separated by sampling_interval seconds; just need to offset
            % each sample's index by the number that precede the impact to calculate
            % the offset in milliseconds.
                Accel_timestamps = ((Data_Accel.Index-presamples+1)*sampling_interval);
                
        Data_Accel.Timestamp = Accel_timestamps.*1000;
            
%% Convert Accel to g
    % Use slope and offset to create calibrated values
        Accel_X_Cal = (Data_Accel.AccelX-1560)./7;
        Accel_Y_Cal = (Data_Accel.AccelY-1560)./7;
        Accel_Z_Cal = (Data_Accel.AccelZ-1560)./7;
        
    % Create new table
        Accel_cal = [Data_Accel.Impact, Data_Accel.Index, Accel_X_Cal, Accel_Y_Cal, Accel_Z_Cal, Data_Accel.Timestamp]; 
    % Restructure to same shape as original table with same column names
        Data_Accel_Cal = array2table(Accel_cal, 'VariableNames', {'Impact' 'Index' 'AccelX' 'AccelY' 'AccelZ' 'Timestamp'});

%% Find mean, min, and max g value at timestamp 0
    %Resultant of linear values
        Linear_Resultant = sqrt(Data_Accel_Cal.AccelX.^2+Data_Accel_Cal.AccelY.^2+Data_Accel_Cal.AccelZ.^2);
        [Zeros,~] = find(all(Data_Accel.Timestamp==0,2));
            Linear_Resultant_Zeros = Linear_Resultant(Zeros,:);
    
    %Mean, Min, and Max
        Linear_Resultant_Mean = round(mean(Linear_Resultant_Zeros),2);
        Linear_Resultant_Min = round(min(Linear_Resultant_Zeros),2);
        Linear_Resultant_Max = round(max(Linear_Resultant_Zeros),2);

    
    %% Filter Accel
    %%mp_filter filters DATA columns using a fourth-order butterworth lowpass filter
    %%with the desired cutoff frequency (fc) and sampling rate (fs) if those are given

    % Accel
    if isempty(Filter.fc_accel) == 1 && isempty(Filter.fs_accel) == 1
        Accel_X_Cal_Filt = Data_Accel_Cal.AccelX;
        Accel_Y_Cal_Filt = Data_Accel_Cal.AccelY;
        Accel_Z_Cal_Filt = Data_Accel_Cal.AccelZ;
    else
            Accel_X_Cal_Filt = j211filtfilt(Filter.fc_accel,Filter.fs_accel,Data_Accel_Cal.AccelX);
            Accel_Y_Cal_Filt = j211filtfilt(Filter.fc_accel,Filter.fs_accel,Data_Accel_Cal.AccelY);
            Accel_Z_Cal_Filt = j211filtfilt(Filter.fc_accel,Filter.fs_accel,Data_Accel_Cal.AccelZ);
    end
            
        % Create new table
            Accel_cal_filt = [Data_Accel_Cal.Impact, Data_Accel_Cal.Index, Accel_X_Cal_Filt, Accel_Y_Cal_Filt, Accel_Z_Cal_Filt, Data_Accel_Cal.Timestamp]; 
        
        % Restructure to same shape as original table with same column names
            Data_Accel_Cal_Filt = array2table(Accel_cal_filt, 'VariableNames', {'Impact' 'Index' 'AccelX' 'AccelY' 'AccelZ' 'Timestamp'});
           
%% Zero Accel
    % Zeroes each event based on the first 8 impacts of the duration (each
    % event will start at 0)
    for zero = 1:Events
            AccelX_zero = mean(Data_Accel_Cal_Filt.AccelX((zero*282-281):(zero*282-274),1));
            AccelY_zero = mean(Data_Accel_Cal_Filt.AccelY((zero*282-281):(zero*282-274),1));
            AccelZ_zero = mean(Data_Accel_Cal_Filt.AccelZ((zero*282-281):(zero*282-274),1));
           
                Accel_X_Cal_Filt_Zero((zero*282-281):(zero*282),1) = Data_Accel_Cal_Filt.AccelX((zero*282-281):(zero*282),1)-AccelX_zero; % Zeroes the circuit impacts
                Accel_Y_Cal_Filt_Zero((zero*282-281):(zero*282),1) = Data_Accel_Cal_Filt.AccelY((zero*282-281):(zero*282),1)-AccelY_zero; % Zeroes the circuit impacts
                Accel_Z_Cal_Filt_Zero((zero*282-281):(zero*282),1) = Data_Accel_Cal_Filt.AccelZ((zero*282-281):(zero*282),1)-AccelZ_zero; % Zeroes the circuit impacts
    end
    
    % Create new table
        Accel_cal_filt_zero = [Data_Accel_Cal_Filt.Impact, Data_Accel_Cal_Filt.Index, Accel_X_Cal_Filt_Zero, Accel_Y_Cal_Filt_Zero, Accel_Z_Cal_Filt_Zero, Data_Accel_Cal_Filt.Timestamp]; 
        
    % Restructure to same shape as original table with same column names
        Data_Accel_Cal_Filt_Zero = array2table(Accel_cal_filt_zero, 'VariableNames', {'Impact' 'Index' 'AccelX' 'AccelY' 'AccelZ' 'Timestamp'});
        
%% Remove Junk

Delete_Impact = [];
% Counter = 1;
        for Max_Events = 1:length(voltage)
            if voltage(Max_Events,1)<3.257
                Delete_Impact = Max_Events;
                break
            end
        end

if isempty(Delete_Impact) == 0
    for Delete = Delete_Impact:length(voltage)
        Indices = find(Data_Accel_Cal_Filt_Zero.Impact == Delete);
            Data_Accel_Cal_Filt_Zero(Indices,:) = []; %#ok<FNDSB>
    end
end

%% Time
    % Converts Epoch datetime to EST datetime
    time_reference = datenum('1970', 'yyyy');
    for q = 1:length(Date_Time) 
        if Date_Time(q,1) > 1541314800 && Date_Time(q,1) < 1552201200
            Time_Date_Temp(q,1) = (time_reference+(Date_Time(q,1)-14400-3600)./8.64e4); % 14400 for EST, 3600 for non-DST
        else
            Time_Date_Temp(q,1) = (time_reference+(Date_Time(q,1)-14400)./8.64e4); % 14400 for EST
        end
    end
    Time_Date_Full = datestr(Time_Date_Temp, 'yyyymmdd HH:MM:SS.FFF');
    [m,~] = size(Time_Date_Full);
        Last_Time = cellstr(Time_Date_Full(m,:));

%% Note the number of events this MP had
    Impact_unique = length(unique(Data_Accel_Cal_Filt_Zero.Impact));

%% Check for Gyro error 
    %(checking random gyro sample)
    if Data.GyroX(22) == 0 && Data.GyroX(22) == 0 && Data.GyroX(22) == 0
        Gyro_Error = {'Gyro Error: Check .csv'};
    else
        Gyro_Error = {'No Error'};
    end

%% Create Post Process 
                
    Post_Process_Temp_1 = num2cell([MP_name,Events,Impact_unique,Voltage_Min,Linear_Resultant_Mean,Linear_Resultant_Min,Linear_Resultant_Max]);
    Post_Process_Temp_2 = [Post_Process_Temp_1{1:3},Last_Time,Gyro_Error,Post_Process_Temp_1{4:7}];
    
    Post_Process_Temp = [Post_Process_Temp;Post_Process_Temp_2];
    
end 
end            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            