% raw2transformed.m should be run BEFORE this script is run.

% This script will take all transformed data (lin accel, rot accel, rot
% velo), along with all meta data associated with each impact (impact type, session type, max values, confirmation
% via film review) and store it all in a single mat file.

% The following folders and files must be present inside the project folder
% for this script to work correctly.

% % %

% PROJECT FOLDER 
% |
% | transformed2mat.m (THIS FILE MUST BE PLACED IN YOUR PROJECT FOLDER)
% |
% |---functions  
% |     This folder contains a collection of functions written to
% |     achieve the calibration and transformation. Copy the function
% |     folder from the directory where this script was copied from and paste it
% |     in your new project directory.
% |   
% |---data
% |   |
% |   |---confirmed_impacts
% |       | MP##_confirmed_impacts.xlsx (Must be a file for each MP, e.g. MP55_confirmed_impacts.xlsx)
% |             Each sheet of this excel file corresponds to a date and should be named after that date (e.g. "4.26.18"). 
% |             In each sheet, there are two columns: Impact_Number, Impact_Type. See README.txt inside the project folder for 
% |             protocol on creating this excel file.
% |   |
% |   |
% |   |---transformed
% |       |
% |       |----MP## - Calibrated_Transformed (There must be a folder for every mouthpiece associated with the project (e.g. MP55 - Calibrated_Transformed) ).
% |            | This folder contains the excel file of transformed data for every impact experienced by the MP (e.g. MP55 - Game - 100impacts - 4.17.18 - Calibrated - T1 - 18.57.42 - Transformed.xlsx)

% % %
%--------------------------------------------------------------------------

%% manual inputs
clc; clear;

project_folder = pwd;

%% convert to mat file

saveFolder = strcat(project_folder, '\data');
functions_folder = strcat(project_folder, '\functions');
confirmed_impacts_folder = strcat(project_folder, '\data\confirmed_impacts');
transformedFolder = strcat(project_folder, '\data\transformed');
mp_transform_folders = dir(transformedFolder);
addpath(functions_folder);

MONTHS = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};
UNITS.lin_accel = 'g';
UNITS.gyro = 'rad/s';
UNITS.rot_accel = 'rad/s^2';
UNITS.time = 's';

for i = 3:length(mp_transform_folders) % loop through MPs, start at 3
    current_mp_dir = fullfile(mp_transform_folders(i).folder, mp_transform_folders(i).name);
    transformed_impact_files = dir(current_mp_dir);
    mp_id = mp_transform_folders(i).name(1:4);
    confirmed_impacts_file = fullfile(confirmed_impacts_folder,strcat(mp_id,'_confirmed_impacts.xlsx'));
    DATE_TRANSFORMED_DATA = [];
    MP_TRANSFORMED_DATA = [];
    current_date = [];
    
    for impact_iterator = 3:length(transformed_impact_files) % loop through MP impacts, start at 3   
        first_impact_of_date = false;
        current_impact_file = fullfile(transformed_impact_files(impact_iterator).folder, transformed_impact_files(impact_iterator).name);
        impact_data = readtable(current_impact_file);
        [~, impact_name] = fileparts(current_impact_file);
        impact_name_parts = strtrim(strsplit(impact_name, '-'));
        session_type = impact_name_parts{2};
        impact_limit = impact_name_parts{3};
        impact_date = impact_name_parts{4};
        impact_number = impact_name_parts{6};
        impact_time = impact_name_parts{7};
                       
        % create stucture field for each date. on each new date, add the previous date structure to the MP data structure and then clear the
        % date structure. also, read in the confirmed impact for the
        % current mouthpiece on the current date.
        if (~strcmp(current_date, impact_date) && impact_iterator > 3)
            current_date = impact_date;
            date_parts = strsplit(prev_date,'.');
            month = MONTHS{str2double(date_parts{1})};
            prev_date_new = strcat(month, '_', date_parts{2}, '_', date_parts{3});          
            MP_TRANSFORMED_DATA.(prev_date_new) = DATE_TRANSFORMED_DATA;
            DATE_TRANSFORMED_DATA = [];
            DATE_TRANSFORMED_DATA.SessionType = session_type;
            confirmed_impacts_table = readtable(confirmed_impacts_file,'Sheet',current_date);
            mp_confirmed_impacts = confirmed_impacts_table.Impact_Number;
            impact_descriptions = confirmed_impacts_table.Impact_Type;
        elseif (impact_iterator == 3)
            current_date = impact_date;
            DATE_TRANSFORMED_DATA.SessionType = session_type;
            confirmed_impacts_table = readtable(confirmed_impacts_file,'Sheet',current_date);
            mp_confirmed_impacts = confirmed_impacts_table.Impact_Number;
            impact_descriptions = confirmed_impacts_table.Impact_Type;
        end
        
        % get resultant values
        res_lin_acc = sqrt(impact_data.AccelX.^2 + impact_data.AccelY.^2 + impact_data.AccelZ.^2);
        res_rot_velo = sqrt(impact_data.GyroX.^2 + impact_data.GyroY.^2 + impact_data.GyroZ.^2);
        res_rot_acc = sqrt(impact_data.AngAccX.^2 + impact_data.AngAccY.^2 + impact_data.AngAccZ.^2);
        
        % get max values (absolute maximums, with correct sign)
        MAX.ResLinAcc = absmax(res_lin_acc);
        MAX.ResRotVelo = absmax(res_rot_velo);
        MAX.ResRotAcc = absmax(res_rot_acc);
        MAX.accelX = absmax(impact_data.AccelX);
        MAX.accelY = absmax(impact_data.AccelY);
        MAX.accelZ = absmax(impact_data.AccelZ);
        MAX.gyroX = absmax(impact_data.GyroX);
        MAX.gyroY = absmax(impact_data.GyroY);
        MAX.gyroZ = absmax(impact_data.GyroZ);
        MAX.rot_accelX = absmax(impact_data.AngAccX);
        MAX.rot_accelY = absmax(impact_data.AngAccY);
        MAX.rot_accelZ = absmax(impact_data.AngAccZ);
        
        % create information structure
        IMPACT_INFO.MP = mp_id;
        IMPACT_INFO.Date = impact_date;
        IMPACT_INFO.Time = impact_time;
        IMPACT_INFO.Number = str2double(impact_number(2:end));
        IMPACT_INFO.Type = session_type;
        IMPACT_INFO.Limit = impact_limit;
        IMPACT_INFO.Confirmed = false;
        IMPACT_INFO.Max = MAX;
        IMPACT_INFO.Units = UNITS;
        IMPACT_INFO.Description = 'not confirmed';
        
        % check if impact has been confirmed via film review
        for confirmed_iter = 1:length(mp_confirmed_impacts)
            if (IMPACT_INFO.Number == mp_confirmed_impacts(confirmed_iter))
                IMPACT_INFO.Confirmed = true;
                IMPACT_INFO.Description = impact_descriptions{confirmed_iter};
            end
        end
        
        % create structure for current impact
        IMPACT_TRANSFORMED_DATA.Info = IMPACT_INFO;
        IMPACT_TRANSFORMED_DATA.Data = impact_data;
        
        % add current impact to the data strucutre for current date
        DATE_TRANSFORMED_DATA.(strcat('Impact',impact_number(2:end))) = IMPACT_TRANSFORMED_DATA;
        
        prev_date = impact_date;
               
    end
    
    % store the data for the final date of impacts before saving MP data
    date_parts = strsplit(prev_date,'.');
    month = MONTHS{str2double(date_parts{1})};
    prev_date_new = strcat(month, '_', date_parts{2}, '_', date_parts{3});
    MP_TRANSFORMED_DATA.(prev_date_new) = DATE_TRANSFORMED_DATA;
    
    % store MP data
    TRANSFORMED_DATA.(mp_id) = MP_TRANSFORMED_DATA;
        
end

save(strcat(saveFolder, '\transformed_data_test.mat'), 'TRANSFORMED_DATA');
