function [Time_Date_Full] = DATA_CALC_EVENT_TIME_v2(Data)

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
        Data_Date = Data(Data.Index<1,:);
            Date_Time = Data_Date.Timestamp;

    % Drop the first record of each impact; don't need the
    % metadata for this example.
        Data = Data(Data.Index>0, :);
    % Renumber the indices so they're 0-based
        Data.Index = Data.Index - 1;
        
%% Remove Junk
    % If the device dies without reaching the requested # of impacts, junk
    % data will fil in the missing values. The accelerations of these junk
    % events are never above 1 after being zeroed.
Metadata = Data_Date.AccelX;
    
    % Calculate voltage
        voltage = Metadata./256;
    
Delete_Impact = [];
    for Max_Events = 1:length(voltage)
        if voltage(Max_Events,1)<3.257
            Delete_Impact = Max_Events;
            break
        end
    end

if isempty(Delete_Impact) == 0
    Date_Time(Delete_Impact:length(voltage),:) = [];
end

%% Time
    if isempty(Date_Time) == 0
        % Converts Epoch datetime to EST datetime
        time_reference = datenum('1970', 'yyyy');
        for q = 1:length(Date_Time) 
            if Date_Time(q,1) > 1541314800
                Time_Date_Temp(q,1) = (time_reference+(Date_Time(q,1)-14400-3600)./8.64e4); % 14400 for EST, 3600 for non-DST
            else
                Time_Date_Temp(q,1) = (time_reference+(Date_Time(q,1)-14400)./8.64e4); % 14400 for EST
            end
        end
        Time_Date_Full = datestr(Time_Date_Temp, 'yyyymmdd HH:MM:SS.FFF');
    else
        Time_Date_Full = [];
    end

end 
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            