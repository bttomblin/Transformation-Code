% The first section of this script will take raw data from the mouthpiece and convert the
% data to the correct units. The second section will apply the transformation matrix to the data at the MP CG and transform it to
% the head CG. If a MP-specific transformation matrix is unavailable, the
% first section of the code can be run by itself to calibrate the raw data.

% The following folders and files must be present inside the project folder
% for this script to work correctly.

% % %

% PROJECT FOLDER 
% |
% | raw2transformed.m (THIS FILE MUST BE PLACED IN YOUR PROJECT FOLDER)
% |
% |----functions  
% |      This folder contains a collection of functions written to
% |      achieve the calibration and transformation. Copy the function
% |      folder from the directory where this script was copied from and paste it
% |      in your new project directory.
% |   
% |-----data
% |     |
% |     |----baselines
% |          |
% |          |----MP00## - Calibration Data  (There must be a folder for every mouth piece associated with the project (e.g. MP0055 - Calibration Data) ).
% |               | MP##_Transform.xlsx (MP-specficic transformation matrix. Transforms to coordinate system: positive z up, positive x forward, positive y  to the left.
% |     |
% |     |----calibrated (This folder can be empty but must exist. This script will save calibrated data for each MP here.)
% |     |
% |     |----impact_times (This folder can be empty but must exist. This script will save the impact times for each impact in an Excel file here.)
% |     |
% |     |----raw
% |          |   
% |          |----MP## (There must be a folder for every mouth piece associated with the project (e.g. MP55) )
% |               | MP## - SessionType - #impacts - M.DD.YY.xlsx (There must be an Excel file for each session saved with the following name convention. (e.g. MP55 - Game - 100impacts - 4.17.18.xlsx) )
% |     |
% |     |----transformed (This folder can be empty but must exist. This script will save transformed data for each MP here.)

% % %
%--------------------------------------------------------------------------
%% Manual input for cutoff freqs and sample rates.
clc; clear; close all;

% project_folder is the current working directory
project_folder = pwd;
% MPs die below 3.27 V
voltage_threshold = 3.27;

% define filtering characteristics
a_cfc = 1000; % use w/ VT filtering function (SAE J211 4 pole butter LPF)
a_fs = 4684; % accel sample rate (Hz)
g_cfc = 155; % use w/ VT filtering function
g_fs = 4684; % gyro sample rate (Hz), halved when remove duplicates, 4684 when interpolate before filter 

%% adding folders to path

% add functions folder to the path
addpath(fullfile(project_folder, 'functions'))

% folder containing raw data to be calibrated: 
rawFolder = strcat(project_folder, '\data\raw');

% folder containing calibration output for devices
baselineFolder = strcat(project_folder, '\data\baselines');

%% Calibrate Raw Data

% This section of the scipt combines the functions necessary to calibrate MP data
% and outputs in the file format desired for use with the transformation
% section of the script.

% create new folder to store calibration output files
[u, ~] = fileparts(rawFolder);
calFolder = strcat(u, '\calibrated');
if ~(7==exist(calFolder, 'dir'))
    mkdir(calFolder);
end

% create new folder to store impact time output files
[u, ~] = fileparts(rawFolder);
timeFolder = strcat(u, '\impact_times');
if ~(7==exist(timeFolder, 'dir'))
    mkdir(timeFolder);
end

% find all folders in raw data folder
rawFolders = dir(rawFolder);

for k = 3:length(rawFolders) % start at 3 b/c first 2 folders created with dir contain metadata
    % for each mouthpiece folder in main raw data folder:
    currentFolder = strcat(rawFolders(k).folder, '\', rawFolders(k).name);
    % find all .csv files in folder
    filePattern = fullfile(currentFolder, '*.csv'); 
    theFiles = dir(filePattern);
    % create a folder for each impact location in the main calibration output
    % folder. It will have the same name as the current folder + calibrated
    [up_dir, low_dir] = fileparts(currentFolder);
    newFolder = strcat(low_dir, ' - Calibrated');
    saveFolder = fullfile(calFolder, newFolder);
    if ~(7==exist(strcat(calFolder, '\', newFolder), 'dir'))
        mkdir(calFolder, newFolder);
    end
    
    fprintf('Calibrating data for %s\n', low_dir)
    
    % perform calibration and output files
    for j = 1:length(theFiles) % start at 1
        % for each file in each impact location folder
        baseFileName = theFiles(j).name;
        currentFile = fullfile(currentFolder,baseFileName);
        voltage = getvoltage(currentFile);
        idx_dead = find(voltage < voltage_threshold);
        idx_real = 1:idx_dead(1)-1;
        saveName = strcat(baseFileName(1:end-4), ' - Calibrated.csv');
        general_calibration(currentFile, saveFolder, saveName, idx_real);
        time_and_date = get_impact_time(currentFile);
        output_impact_times(timeFolder, currentFolder, baseFileName, time_and_date);
    end
      
end

%% Transform Calibrated Data

% create folder to store transformed data in
[u, l] = fileparts(calFolder);
tFolder = strcat(u, '\transformed');
if ~(7==exist(tFolder, 'dir'))
    mkdir(tFolder);
end

baselineFolders = dir(baselineFolder); % find all folders in baseline data folder
calibratedFolders = dir(calFolder); % find all folders in calibrated data folder

for k = 3:length(calibratedFolders) % start at 3 b/c first 2 folders created with dir contain metadata
    
    % get file containing transformation info (rotation matrix and position vector) 
    P_ind = strfind(calibratedFolders(k).name,'P');
    space_ind = strfind(calibratedFolders(k).name,' ');
    mp_number = calibratedFolders(k).name(P_ind+1:space_ind(1)-1);
    transform_file = fullfile(baselineFolder, baselineFolders(k).name, strcat('MP', num2str(mp_number), '_Transform.xlsx'));
    mp_time_folder = strcat(timeFolder, '\MP', mp_number);
    mp_number = str2double(mp_number);
    mp_time_files = dir(strcat(mp_time_folder, '\*.csv'));
    
    % for each impact location folder in main raw data folder:
    currentFolder = strcat(calibratedFolders(k).folder, '\', calibratedFolders(k).name);
    
    % find all .csv files in folder
    filePattern = fullfile(currentFolder, '*.csv');
    theFiles = dir(filePattern);
    [up_dir, low_dir] = fileparts(currentFolder);
    newFolder = strcat(low_dir, '_Transformed');
    saveFolder = fullfile(tFolder, newFolder);
    if ~(7==exist(strcat(tFolder, '\', newFolder), 'dir'))
        mkdir(tFolder, newFolder);
    end
 
    fprintf('Transforming data for %s\n', low_dir)
    
    for j = 1:length(theFiles) % start at 1
        % for each file in each impact location folder:
        baseFileName = theFiles(j).name;
        currentFile = fullfile(currentFolder,baseFileName);
        % load calibrated sensor data
        wf_data_all = readtable(currentFile);

        % get time info
        mp_impact_times = readtable(strcat(mp_time_folder, '\', mp_time_files(j).name));
        mp_impact_times = table2array(mp_impact_times);
        
        for i = 0:max(wf_data_all.Impact) % look at one impact at a time, start at 0
                            
            impact_time = char(mp_impact_times(i+1,2));
            impact_time = strrep(impact_time, ':', '.');               
                       
            % extract accel and gyro data
            wf_data = wf_data_all(wf_data_all.Impact==i, :); 
            wf_accel = [wf_data.AccelX, wf_data.AccelY, wf_data.AccelZ];
            wf_gyro = [wf_data.GyroX, wf_data.GyroY, wf_data.GyroZ].*(pi/180); % convert to rad/s
            accel_time = round(wf_data.AccelTime, 5); % round timestamps to remove errors caused by precision during interpolation
            gyro_time = round(wf_data.GyroTime, 5);
            
            % remove duplicate gyroscope data
            [new_gyro_x, new_gyro_y, new_gyro_z, new_time_x, new_time_y, new_time_z] = mp_remove_duplicates(wf_gyro, gyro_time);
            
            % in interp1.m, all of the query values (accel_time) must be <= the last value of X (new_time_X), or else NaN is returned. 
            if(accel_time(end) > new_time_x(end))
                new_time_x(end) = accel_time(end);
            end
            if(accel_time(end) > new_time_y(end))
                new_time_y(end) = accel_time(end);
            end
            if(accel_time(end) > new_time_z(end))
                new_time_z(end) = accel_time(end);
            end
            
            % interpolate
            g_interp_x = mp_gyro_interp(new_time_x, new_gyro_x, accel_time);
            g_interp_y = mp_gyro_interp(new_time_y, new_gyro_y, accel_time);
            g_interp_z = mp_gyro_interp(new_time_z, new_gyro_z, accel_time);

            % filter data
            g_filt_x = j211filtfilt(g_cfc, g_fs, g_interp_x);
            g_filt_y = j211filtfilt(g_cfc, g_fs, g_interp_y);
            g_filt_z = j211filtfilt(g_cfc, g_fs, g_interp_z);
            a_filt = j211filtfilt(a_cfc, a_fs, wf_accel); 
            
            % zero offset
            a_zero = mp_zero_offset(a_filt);
            g_zero_x = mp_zero_offset(g_filt_x);
            g_zero_y = mp_zero_offset(g_filt_y);
            g_zero_z = mp_zero_offset(g_filt_z);
            g_zero = [g_zero_x, g_zero_y, g_zero_z];
  
            % rotate
            [r_cg, r_accel, r_gyro] = read_transformation_info(transform_file);
            a_rotated = mp_rotation_accel(r_accel, a_zero);
            g_rotated = mp_rotation_gyro(r_gyro, g_zero);
            
            % calc rotational accel
            % calculated using VT method; added row in beginning to preserve
            % vector length. g should start at 0 0 0, additional timestep
            % should be 0.2ms before first.
            % rot_acc = diff([0 0 0;g_rotated])./diff([-0.0154; wf_data.AccelTime]); 
            rot_acc = mp_angular_accel(accel_time, g_rotated);
            
            % transform
            a_trans = mp_transform(r_cg, a_rotated, g_rotated, rot_acc);
            a_trans = [a_trans(:,1), a_trans(:,2), a_trans(:,3)];
            
            % create table that contains transformed data
            % has time, transformed accel (x,y,z), rotated gyro (x,y,z), and
            % rotated ang accel (x,y,z) for easy comparison to VT data
            trans_table = table(accel_time, a_trans(:,1), a_trans(:,2), a_trans(:,3),...
                g_rotated(:,1), g_rotated(:,2), g_rotated(:,3), rot_acc(:,1), rot_acc(:,2), rot_acc(:,3),...
                'VariableNames', {'Time', 'AccelX', 'AccelY', 'AccelZ', 'GyroX', 'GyroY', 'GyroZ', 'AngAccX', 'AngAccY', 'AngAccZ'});
            
            % save file in folder
            test = sprintf('T%d', i+1); % test number is impact index+1
            saveFile = strcat(baseFileName(1:end-4),' - ', test, ' - ', impact_time, ' - Transformed', '.csv');
            save_file_name = fullfile(saveFolder, saveFile);
            if ~isfolder(saveFolder)
                error('Error: The folder does not exist.'); 
            end
            writetable(trans_table, save_file_name); % write combined table to csv using new filename
            fprintf('Saved data for Impact %d: %s\n',i+1, saveFile);
        end
    end
end