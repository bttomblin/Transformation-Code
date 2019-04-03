function [Post_Process_Temp,modename] = QC_Function(Data,Title_initial,Post_Process_Temp)

% Determine whether the data file has 1 meta line (old firmware) or 2 (new firmware)
    % In 1 meta line versions, AccelX is the voltage read and is always above ~800
    
%% Calculate table data
% 2 Meta Lines
    if Data.AccelX(1) < 600
        % Get name of MP
            ind_Space = strfind(Title_initial," ");
            ind_MP = strfind(Title_initial,"MP");
                MP_name = str2double(Title_initial(ind_MP(1,1)+2:ind_Space(1,1)-1));

        % Create Impact Index
            %determine if impact or interval mode was used to collect Data
            %Timestamp in first metaData row contains this information in 4-byte
            %structure:    
                capture_mode = bitand(bitshift(Data.Timestamp(1), -16, 'int32'), 65535, 'int32');

            %calculate sample rate from tick interval input (65536/tick), stored in
            %GyroX
                sample_rate = 65536/Data.GyroX(1);

            if capture_mode == 64222 %this corresponds to impact mode
                %for impact mode, include pre impact samples (stored in AccelY)
                %add two for two meta-Data samples per impact collected
                    samples_per_impact = Data.AccelZ(1)+2+Data.AccelY(1);
                    mode = 1;
                    modename = 'Impact';
                %store metData in a table so it can be accessed later,
                %since it will not be stored in impact table ("Data")
                    MetaTable = table(mode, Data.AccelY(1), Data.AccelZ(1), sample_rate,...
                        'VariableNames', {'CaptureMode', 'PreSamples', 'PostSamples', 'SampleRate'});

            elseif capture_mode == 47838 %this corresponds to interval mode
                %interval mode, number of samples stored in AccelZ.
                    samples_per_impact = Data.AccelZ(1)+2;
                    mode = 2;
                    modename = 'Interval';
                %store metData in a table so it can be accessed later,
                %since it will not be stored in impact table ("Data")
                    MetaTable = table(mode,  Data.AccelZ(1), sample_rate,...
                        'VariableNames', {'CaptureMode', 'Samples', 'SampleRate'});
            else 
                error('Data collection mode not recognized');
            end
            
        % Check that all samples were downloaded correctly
            if rem(height(Data),samples_per_impact) ~= 0
                errornumber = height(Data)/samples_per_impact;
                fprintf('\nERROR: %s has samples for only %.2f impacts. Excluded from quality check. Redownload Data.\n',Title_initial,errornumber)
            else
                % Add a column with each record's impact number, and renumber the
                % indices so that each impact's indices count up from zero.
                    Data.Impact = floor(Data.Index/samples_per_impact)+1;
                    Data.Index = mod(Data.Index,samples_per_impact);

                % Separate Date timestamps.
                    Recurring_MetaData = Data(Data.Index<2,:);
                        Date_Time = Recurring_MetaData.Timestamp(2:2:length(Recurring_MetaData.Timestamp));
                        
                % Find Voltages
                    Recurring_MetaData_Voltage = Recurring_MetaData.AccelX(2:2:length(Recurring_MetaData.AccelX));

                % Calculate voltage
                    Voltage = Recurring_MetaData_Voltage./256;
                    Voltage_Min = round(min(Voltage),3);
        
                % Prepare Data file for rest of formatting
                    % Drop the first record of each impact; don't need the
                    % metaData for this example.
                        Data = Data(Data.Index>1, :);
                    % Renumber the indices so they're 0-based
                        Data.Index = Data.Index - 2;
        
                % Separate Accel
                    Data_Accel = Data(:,{'Impact','Index','AccelX','AccelY','AccelZ'});
                    Events = max(Data_Accel.Impact);
        
                % Convert Accel Timesteps              
                    % Derived Values
                        % The amount of time that passes between each accelerometer sample
                            sampling_interval = 1 / MetaTable.SampleRate;

                        if MetaTable.CaptureMode == 1
                            % The number of samples that precede the point of impact.
                                presamples = MetaTable.PreSamples;
                                timestamps = (Data.Index - presamples) * sampling_interval;
                        elseif MetaTable.CaptureMode == 2
                            timestamps = (Data.Index*sampling_interval);
                        end

                    Data_Accel.Timestamp = timestamps.*1000;
                        Time = max(Data_Accel.Timestamp) - min(Data_Accel.Timestamp);            
                        
                        if MetaTable.CaptureMode == 1
                            TimeWords = sprintf('%.1f ms',Time);
                        else
                            TimeWords = sprintf('%.1f s',Time);
                        end

                % Convert Accel to g
                    % Use slope and offset to create calibrated values
                        Accel_X_Cal = (Data_Accel.AccelX-1560)./7;
                        Accel_Y_Cal = (Data_Accel.AccelY-1560)./7;
                        Accel_Z_Cal = (Data_Accel.AccelZ-1560)./7;

                    % Create new table
                        Accel_cal = [Data_Accel.Impact, Data_Accel.Index, Accel_X_Cal, Accel_Y_Cal, Accel_Z_Cal, Data_Accel.Timestamp]; 
                    % Restructure to same shape as original table with same column names
                        Data_Accel_Cal = array2table(Accel_cal, 'VariableNames', {'Impact' 'Index' 'AccelX' 'AccelY' 'AccelZ' 'Timestamp'});
        
                % Find mean, min, and max g value at timestamp 0
                    %Resultant of linear values
                        Linear_Resultant = sqrt(Data_Accel_Cal.AccelX.^2+Data_Accel_Cal.AccelY.^2+Data_Accel_Cal.AccelZ.^2);
                        [Zeros,~] = find(all(Data_Accel.Timestamp==0,2));
                            Linear_Resultant_Zeros = Linear_Resultant(Zeros,:);

                    %Mean, Min, and Max
                        Linear_Resultant_Mean = round(mean(Linear_Resultant_Zeros),2);
                        Linear_Resultant_Min = round(min(Linear_Resultant_Zeros),2);
                        Linear_Resultant_Max = round(max(Linear_Resultant_Zeros),2);

                % Remove Junk
                    % Determine if the battery started to die
                        Delete_Impact = [];
                                for Max_Events = 1:length(Voltage)
                                    if Voltage(Max_Events,1)<3.257
                                        Delete_Impact = Max_Events;
                                        break
                                    end
                                end
                    % If the battery did die, delete the impacts that occurred after
                        if isempty(Delete_Impact) == 0
                            for Delete = Delete_Impact:length(Voltage)
                                Indices = find(Data_Accel_Cal.Impact == Delete);
                                    Data_Accel_Cal(Indices,:) = []; %#ok<FNDSB>
                            end
                        end
        
                % Time
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
        
                % Note the number of events this MP had
                    Impact_unique = length(unique(Data_Accel_Cal.Impact));
                    
                % Check for Gyro error 
                    if mean(Data.GyroX(22:25) == 0) == 1 && mean(Data.GyroY(22:25) == 0) == 1 && mean(Data.GyroZ(22:25) == 0) == 1  %(checking random gyro samples)
                        Gyro_Error = {'Gyro Error: Check .csv'};
                    else
                        Gyro_Error = {'No Error'};
                    end
                    
                % Create Post Process Table
                    if MetaTable.CaptureMode == 1 % Impact
                        Post_Process_Temp_1 = num2cell([MP_name,Events,Impact_unique,Voltage_Min,Linear_Resultant_Min,Linear_Resultant_Mean,Linear_Resultant_Max]);
                        Post_Process_Temp_2 = [Post_Process_Temp_1{1:3},Last_Time,Gyro_Error,TimeWords,Post_Process_Temp_1{4:7}];

                            Post_Process_Temp = [Post_Process_Temp;Post_Process_Temp_2];
                            
                    elseif MetaTable.CaptureMode == 2 % Interval
                        Post_Process_Temp_1 = num2cell([MP_name,Events,Impact_unique,MetaTable.Samples,Voltage_Min]);
                        Post_Process_Temp_2 = [Post_Process_Temp_1{1:3},Last_Time,Gyro_Error,TimeWords,Post_Process_Temp_1{4:5}];

                            Post_Process_Temp = [Post_Process_Temp;Post_Process_Temp_2];
                    end
            end
            
% 1 Meta Line
    else
        % Get name of MP
            ind_Space = strfind(Title_initial," ");
            ind_MP = strfind(Title_initial,"MP");
                MP_name = str2double(Title_initial(ind_MP(1,1)+2:ind_Space(1,1)-1));

        % Mode name
            modename = 'Impact';
            
        % Create Impact Index
            % This value is hard-coded because it can't be derived from the data.
            % Alternatively, this function could be refactored to provide the
            % samples/impact as an argument.
                samples_per_impact = 283;
            
        % Check that all samples were downloaded correctly
            if rem(height(Data),samples_per_impact) ~= 0
                errornumber = height(Data)/samples_per_impact;
                fprintf('\nERROR: %s has samples for only %.2f impacts. Excluded from quality check. Redownload Data.\n',Title_initial,errornumber)
            else
                % Add a column with each record's impact number, and renumber the
                % indices so that each impact's indices count up from zero.
                    Data.Impact = floor(Data.Index/samples_per_impact)+1;
                    Data.Index = mod(Data.Index,samples_per_impact);

                % Separate Date timestamps.
                    Metadata = Data(Data.Index<1,:);
                        Date_Time = Metadata.Timestamp;
                        
                % Calculate voltage
                    Voltage = Metadata.AccelX./256;
                    Voltage_Min = round(min(Voltage),3);
        
                % Prepare Data file for rest of formatting
                    % Drop the first record of each impact; don't need the
                    % metaData for this example.
                        Data = Data(Data.Index>0, :);
                    % Renumber the indices so they're 0-based
                        Data.Index = Data.Index - 1;
        
                % Separate Accel
                    Data_Accel = Data(:,{'Impact','Index','AccelX','AccelY','AccelZ'});
                    Events = max(Data_Accel.Impact);
        
                % Convert Accel Timesteps              
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
                        Time = max(Data_Accel.Timestamp) - min(Data_Accel.Timestamp);            
                        TimeWords = sprintf('%.1f ms',Time);

                % Convert Accel to g
                    % Use slope and offset to create calibrated values
                        Accel_X_Cal = (Data_Accel.AccelX-1560)./7;
                        Accel_Y_Cal = (Data_Accel.AccelY-1560)./7;
                        Accel_Z_Cal = (Data_Accel.AccelZ-1560)./7;

                    % Create new table
                        Accel_cal = [Data_Accel.Impact, Data_Accel.Index, Accel_X_Cal, Accel_Y_Cal, Accel_Z_Cal, Data_Accel.Timestamp]; 
                    % Restructure to same shape as original table with same column names
                        Data_Accel_Cal = array2table(Accel_cal, 'VariableNames', {'Impact' 'Index' 'AccelX' 'AccelY' 'AccelZ' 'Timestamp'});
        
                % Find mean, min, and max g value at timestamp 0
                    %Resultant of linear values
                        Linear_Resultant = sqrt(Data_Accel_Cal.AccelX.^2+Data_Accel_Cal.AccelY.^2+Data_Accel_Cal.AccelZ.^2);
                        [Zeros,~] = find(all(Data_Accel.Timestamp==0,2));
                            Linear_Resultant_Zeros = Linear_Resultant(Zeros,:);

                    %Mean, Min, and Max
                        Linear_Resultant_Mean = round(mean(Linear_Resultant_Zeros),2);
                        Linear_Resultant_Min = round(min(Linear_Resultant_Zeros),2);
                        Linear_Resultant_Max = round(max(Linear_Resultant_Zeros),2);

                % Remove Junk
                    % Determine if the battery started to die
                        Delete_Impact = [];
                                for Max_Events = 1:length(Voltage)
                                    if Voltage(Max_Events,1)<3.257
                                        Delete_Impact = Max_Events;
                                        break
                                    end
                                end
                    % If the battery did die, delete the impacts that occurred after
                        if isempty(Delete_Impact) == 0
                            for Delete = Delete_Impact:length(Voltage)
                                Indices = find(Data_Accel_Cal.Impact == Delete);
                                    Data_Accel_Cal(Indices,:) = []; %#ok<FNDSB>
                            end
                        end
        
                % Time
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
        
                % Note the number of events this MP had
                    Impact_unique = length(unique(Data_Accel_Cal.Impact));
                    
                % Check for Gyro error 
                    if mean(Data.GyroX(22:25) == 0) == 1 && mean(Data.GyroY(22:25) == 0) == 1 && mean(Data.GyroZ(22:25) == 0) == 1  %(checking random gyro samples)
                        Gyro_Error = {'Gyro Error: Check .csv'};
                    else
                        Gyro_Error = {'No Error'};
                    end
                    
                % Create Post Process Table
                    Post_Process_Temp_1 = num2cell([MP_name,Events,Impact_unique,Voltage_Min,Linear_Resultant_Min,Linear_Resultant_Mean,Linear_Resultant_Max]);
                    Post_Process_Temp_2 = [Post_Process_Temp_1{1:3},Last_Time,Gyro_Error,TimeWords,Post_Process_Temp_1{4:7}];

                        Post_Process_Temp = [Post_Process_Temp;Post_Process_Temp_2];
            end
    end

end

















