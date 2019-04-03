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

            [Post_Process_Temp,modename] = QC_Function(Data,Title_initial,Post_Process_Temp);
        
        clearvars -except DataFolders Files_Names x Filter Post_Process_Temp q iii Quality_Check modename

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
    
        Session_find = strfind(Files_Names{1,1},'-');
        Session = Files_Names{1,1}(Session_find(1,1)+2:Session_find(1,2)-2);
    
    Quality_Check{iii,1}.Date = Date;
    Quality_Check{iii,1}.Session = Session;
    Quality_Check{iii,1}.Mode = modename;
    Quality_Check{iii,1}.Table = Quality_Check_Table;
        iii = iii+1;
    clearvars -except DataFolders Quality_Check iii q Filter
    
end

fprintf('Approximate # impacts per MP per session: \n')
for i=1:length(Quality_Check)
    fprintf('%s: Activated MPs: %.0f \t Events per MP: %.1f\n', Quality_Check{i}.Date, length(Quality_Check{i}.Table.Non_Junk_Events), sum(Quality_Check{i}.Table.Non_Junk_Events)/length(Quality_Check{i}.Table.Non_Junk_Events))
        % NOTE: ACTIVATED MPS DO NOT MEAN THEY WORKED CORRECTLY. CHECK STRUCTURE
end

clearvars -except DataFolders Quality_Check 
    