%% NOTES
% Inputs:
%   MP_Data_Folder: path to the raw .csv MP files correlating to the video you are reviewing
%   VideoStartTime: the real-world start time from the time sync at the
%       beginning the video. if there are two videos for a single session, make
%       a matrix (more details below)
% Outputs:
%   Time_Differences: the video times for every event recorded by the MP.
%       The first cell will be the MP name. If there is more than one video,
%       the cells will be separated into "Video_1," "Video_2," etc. Press
%       continue to go to the next MP variable.

%% Clears and closes everything to start
close all;
clear;
clc;
%#ok<*NBRAK>

dbstop in RUN_ME_Video_Time at 61

%% Manual Inputs: 
    MP_Data_Folder = '\\medctr\dfs\cib$\hits\Soccer\01_Player_Data_Video\2018_Fall\01_MP_Data\U16\11.01.18';
        addpath(MP_Data_Folder)
        
% Use military time. If more than one start time, use format: ['08:43:48.00';'09:50:07.00'] etc
    VideoStartTime = ['18:05:34.00'];
   
%% Find Files
    File_Structure=dir((MP_Data_Folder)); % Finds files in current folder with this start

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
        if isempty(Files_Names) == 1
           error('No files found in folder. Check "MP_Cal_Folder" pathway');
        end
    
%% Calculate Time Differences
% Time_Differences = [];
    for x = 1:length(Files_Names)
        Data = readtable(Files_Names{x,1});
        Title_initial = Files_Names{x,1};
                    
        % Calculate Time of Each Event
            [Time_Date_Full] = DATA_CALC_EVENT_TIME_v2(Data);

        % Calculate the Difference Between Each Event Time and Video Time
            [Time_Differences] = CALC_TIME_DIFF(Title_initial,Time_Date_Full,VideoStartTime);
        
            a_OPEN_ME = Time_Differences;
        clearvars -except Files_Names x VideoStartTime
        close all
    end


















