%% NOTES
% Inputs:
%   DataFolders: Folders with raw .csv files labeled by date (follow soccer data folder structure)
%
% Outputs:
%   DataFolders: List of input folders
%   Quality_Check:
%       Date: Date of data being quality checked (based on folder)
%       Table: Quality check event values with:
%          MP: MP name
%          Recorded_Events: Total number of events recorded
%          Non_Junk_Events: Total number of events not caused by battery death
%          Time_Last_Event: Time of last recorded event
%          Gyro_Error: If the MP did not record gyro data correctly
%          Voltage_v_Min: Minimum voltage (v) of the recorded events
%          Event_Duration: Event recording duration
%           For Impact Mode:
%               Trigger_Resultant_g_Min: Minimum resultant linear acceleration (g) at the sample where time = 0 ms
%               Trigger_Resultant_g_Mean: Mean resultant linear acceleration (g) at the sample where time = 0 ms
%               Trigger_Resultant_g_Max: Maximum resultant linear acceleration (g) at the sample where time = 0 ms
%           For Interval Mode:
%               Event_Samples: Samples set to be collected per event
%               Sample_Rate: Sample rate

%
% Notes on Quality Check:
%   MP Not Reset:
%       If date in "Time_Last_Event" is not the correct date
%   Battery Death:
%       If "Recorded Events" > "Non_Junk_Events"
%       If "Voltage_v_Min" < 3.27
%   MP Died Before End of Session
%       If battery died and time in "Time_Last_Event" is earlier than end time of session
%   MP Events Maxed Before End of Session
%       If "Non_Junk_Events" = "Impacts to Collect" setting and time in "Time_Last_Event" is earlier than end time of session

%% Clears and closes everything to start
close all;
clear;
clc;

%% Manual Inputs:
    addpath(fullfile(cd,'Functions_QualityCheck'));
    
    % the path to the downloaded data folder
        disp('Select Data Folder(s):')
    
        DataFolders = uigetdir2;
            if isempty(DataFolders)
                error('No Data Folders Selected')
            end

%% Find Files
iii = 1;

for q = 1:length(DataFolders)
    MP_Cal_Folder = DataFolders{1,q};
        addpath(MP_Cal_Folder)
    File_Structure=dir(fullfile(MP_Cal_Folder,'*.csv')); % Finds files in current folder with this start

    Files = table2cell(struct2table(File_Structure)); % Restructures structure variable to a cell array
    [m,~] = size(Files);

    i_list = []; 
    for i = 1:m
        if Files{i,5} == 1 % For some reason, false files are found in every folder, so this finds them
            i_list = [i_list,i];
        end
    end

    Files(i_list,:) = []; % Removes the false files

    Files_Names = Files(:,1); % Separates out the names of the files from the irrelevant information

    if isempty(Files_Names)
        slash = strfind(MP_Cal_Folder,"\");
        warningmessage = MP_Cal_Folder(slash(length(slash))+1:length(MP_Cal_Folder));
        warning('No .csv Files in Data Folder: %s. Skipped check.',warningmessage)
        continue
    end
    
%% Create Table of Post Process Data
Post_Process_Temp = [];
    for x = 1:length(Files_Names)
        Data = readtable(Files_Names{x,1});
        Title_initial = Files_Names{x,1};
        if isempty(Data)
            fprintf('\nERROR: %s has no values. Excluded from quality check. Redownload Data.\n',Title_initial)
            continue
        else
            [Post_Process_Temp,modename] = QC_Function(Data,Title_initial,Post_Process_Temp);
        
        clearvars -except DataFolders Files_Names x Filter Post_Process_Temp q iii Quality_Check modename
        end
    end

%% Create Final Structure
    if isequal(modename,'Impact')
        Quality_Check_Table = cell2table(Post_Process_Temp,'VariableNames',{'MP'...
            'Recorded_Events' 'Non_Junk_Events' 'Time_Last_Event' 'Gyro_Error'...
            'Event_Duration' 'Voltage_v_Min' 'Trigger_Resultant_g_Min'...
            'Trigger_Resultant_g_Mean' 'Trigger_Resultant_g_Max'});
    else
        Quality_Check_Table = cell2table(Post_Process_Temp,'VariableNames',{'MP'...
            'Recorded_Events' 'Non_Junk_Events' 'Time_Last_Event' 'Gyro_Error'...
            'Event_Duration' 'Event_Samples' 'Sample_Rate' 'Voltage_v_Min'});
    end
    
    Date_find = strfind(DataFolders{1,q},"\");
    Date = DataFolders{1,q}(Date_find(length(Date_find))+1:length(DataFolders{1,q}));
        if length(Date) == 10
            Date(7:8) = [];
        end
    
        Session_find = strfind(Files_Names{1,1},'-');
        Session = Files_Names{1,1}(Session_find(1,1)+2:Session_find(1,2)-2);
        if contains(Session,'mp') || contains(Session,'MP')
            Session = Files_Names{1,1}(Session_find(1,2)+2:Session_find(1,3)-2);
        end
    
    Quality_Check{iii,1}.Date = Date;
    Quality_Check{iii,1}.Session = Session;
    Quality_Check{iii,1}.Mode = modename;
    Quality_Check{iii,1}.Table = Quality_Check_Table;
        iii = iii+1;
    clearvars -except DataFolders Quality_Check iii q Filter
    
end

fprintf('MP Event Summary: \n')
for iiii=1:length(Quality_Check)
    fprintf('\n Structure %.0f, %s: \n \t Activated MPs: %.0f \n \t Average Events per MP: %.1f \n \t Min MP Events: %.0f \n \t Max MP Events: %0.f \n \n',...
        iiii,Quality_Check{iiii}.Date, length(Quality_Check{iiii}.Table.MP),...
        sum(Quality_Check{iiii}.Table.Non_Junk_Events)/length(Quality_Check{iiii}.Table.MP),...
        min(Quality_Check{iiii}.Table.Non_Junk_Events),max(Quality_Check{iiii}.Table.Non_Junk_Events))
        % NOTE: ACTIVATED MPS DO NOT MEAN THEY WORKED CORRECTLY. CHECK STRUCTURE
        
    %% Errors
        for iiiii = 1:length(Quality_Check{iiii}.Table.MP)
            % MP not reset
                datecheck = sprintf('%s.%s.%s',Quality_Check{iiii}.Table.Time_Last_Event{iiiii}(5:6),Quality_Check{iiii}.Table.Time_Last_Event{iiiii}(7:8),Quality_Check{iiii}.Table.Time_Last_Event{iiiii}(3:4));
                if ~isequal(datecheck,Quality_Check{iiii,1}.Date)
                    fprintf('\t Reset Error for MP %.0f \n',Quality_Check{iiii}.Table.MP(iiiii))
                end
            % Battery death
                if Quality_Check{iiii}.Table.Recorded_Events(iiiii) > Quality_Check{iiii}.Table.Non_Junk_Events(iiiii) && Quality_Check{iiii}.Table.Voltage_v_Min(iiiii) < 3.27
                    fprintf('\t Battery Death for MP %.0f \n',Quality_Check{iiii}.Table.MP(iiiii))
                end
            % Gyro Error
                if ~isequal('No Error',char(Quality_Check{iiii}.Table.Gyro_Error(iiiii)))
                    fprintf('\t Gyro Error for MP %.0f \n',Quality_Check{iiii}.Table.MP(iiiii))
                end
        end
end

clearvars -except DataFolders Quality_Check 
    