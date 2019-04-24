close all
clearvars -except impacts
clc

PreImpactTime = 1;
PostImpactTime = 3;

% Date of impact as string as found in Info
impactdate = '20181104';

% MP of impact as string as found in Info
impactmp = 'MP083';

% Time of impact as string as found in Info
impacttime = '08:49:43.000';

% Impact Index (Impact Number - 1)
impactindex = 4;

% Path to transformed data
Path = '\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\Merged_Analysis\Fall2018_Merged_transformedData.mat';

%% Load and make new impact list
if exist('impacts','var') == 0
load(Path);
end

main = [];
for i = 1:length(impacts)
   if isequal(impacts{1,i}.Info.ImpactDate,impactdate)
       if isequal(impacts{1,i}.Info.MouthpieceID,impactmp)
           if isequal(impacts{1,i}.Info.ImpactTime,impacttime)
               if impacts{1,i}.Info.ImpactIndex == impactindex
                   main = impacts{1,i};
                   break
               end
           end
       end
   end
end

if isempty(main)
    error('No Impact Found')
end

%% Make Table of Impacts
    % Label
        Label = main.FilmReview.ImpactType;
    % MP
        MP = main.FilmReview.MouthpieceID;
    % Date
        Date = main.FilmReview.ImpactDate;
            if ~contains(Date,'Game')
                t = datetime(Date,'InputFormat','MMM_dd_yy');
                s = datetime(t,'Format','yyyy-MM-dd');
                Date = char(s);
                Game = 'No Game Number';
            else
                g = strfind(Date,'Game');
                    Game = Date(g:g+4);
                    Date = strcat(Date(1:g-1),Date(length(Date)-1:length(Date)));
                t = datetime(Date,'InputFormat','MMM_dd_yy');
                s = datetime(t,'Format','yyyy-MM-dd');
                Date = char(s);
            end
    % Impact Number
        I = main.FilmReview.ImpactNumber;        
    % Actual Time
        AT = char(main.FilmReview.VideoImpactTime);
    % Video Time
        VT = char(main.FilmReview.FilmTime);

        temp = {Label,MP,Date,Game,I,VT,AT,i};
        
Table = cell2table(temp,'VariableNames',{'Label' 'MP' 'Date' 'Game_Number' 'Impact_Number' 'Video_Time' 'Actual_Time' 'Total_Impact_Number'});

%% Make new videos

    % Find Video Folder based on MP Team
        if contains(Table.MP,'092') || contains(Table.MP,'093') || contains(Table.MP,'103') || contains(Table.MP,'110')
            if contains(Table.Game_Number,'No')
                VideoFolder = strcat('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\2018_Fall_U14\Film_Review\',char(Table.Date));
                    addpath(VideoFolder)
            else
                VideoFolder = strcat('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\2018_Fall_U14\Film_Review\',char(Table.Date),'_',char(Table.Game_Number));
                    addpath(VideoFolder)
            end
        else
            if contains(Table.Game_Number,'No')
                VideoFolder = strcat('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\2018_Fall_U16\Film_Review\',char(Table.Date));
                    addpath(VideoFolder)
            else
                VideoFolder = strcat('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\2018_Fall_U16\Film_Review\',char(Table.Date),'_',char(Table.Game_Number));
                    addpath(VideoFolder)
            end
        end
        
    % Find videos in folder
        File_Structure=dir(fullfile(VideoFolder,'*.mts')); % Finds files in current folder with this start
        if isempty(File_Structure)
            File_Structure=dir(fullfile(VideoFolder,'*.mp4')); % Finds files in current folder with this start
        end
        if isempty(File_Structure)
            error('Either no videos in video folder or videos not in .mts or .mp4 format')
        end
        
    % Video Start/Stop times of new videos (+-1 sec from impact time)
        VideoTime = char(Table.Video_Time);
            VT_1 = duration(VideoTime,'InputFormat','hh:mm:ss');
            VT_2 = seconds(VT_1);
            StartTime = VT_2 - PreImpactTime;
            EndTime = VT_2 + PostImpactTime;
    
    % Make Videos
        % If only 1 video on that day
        if length(File_Structure) == 1
            clc;
            
            fprintf('Making Video \n')

            inputName = strcat(File_Structure.folder,'\',File_Structure.name);
            outputName = strcat(cd,'\','SingleImpact','.mp4');
            
            a = VideoReader(inputName);
            beginFrame = StartTime * a.FrameRate;
            endFrame = EndTime * a.FrameRate;
            vidObj = VideoWriter(outputName,'MPEG-4'); %#ok<*TNMLP>
            
            a.CurrentTime = beginFrame/a.FrameRate;
            open(vidObj);

            while a.CurrentTime <= endFrame/a.FrameRate
                fprintf('Timestep: %.2f / %.2f\n',a.CurrentTime,EndTime)
                b = readFrame(a);
                writeVideo(vidObj,b)
            end
            
            close(vidObj);
        % If 2 videos on that day, need to determine which video has the
        % event based on it's impact time
        else
            clc;
                if contains(Table.MP,'092') || contains(Table.MP,'093') || contains(Table.MP,'103') || contains(Table.MP,'110')
                    SessionTimes = readtable('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\Merged_Analysis\U14_Session_Times.xlsx');
                        SessionTimes.Video_2_Start = datestr(SessionTimes.Video_2_Start,'HH:MM:SS');
                        SessionTimes.Date = datestr(SessionTimes.Date,'yyyy-mm-dd');
                else
                    SessionTimes = readtable('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\Merged_Analysis\U16_Session_Times.xlsx');
                        SessionTimes.Video_2_Start = datestr(SessionTimes.Video_2_Start,'HH:MM:SS');
                        SessionTimes.Date = datestr(SessionTimes.Date,'yyyy-mm-dd');
                end
            
            fprintf('Making Video \n')
            
            for dt = 1:height(SessionTimes)
                if contains(Table.Game_Number,'No')
                    if contains(SessionTimes.Date(dt,:),char(Table.Date))
                        if datetime(SessionTimes.Video_2_Start(dt,:)) > datetime(char(Table.Actual_Time))
                            inputName = strcat(File_Structure(1).folder,'\',File_Structure(1).name);
                            break
                        else
                            inputName = strcat(File_Structure(2).folder,'\',File_Structure(2).name);
                            break
                        end
                    end
                elseif contains(Table.Game_Number,'1')
                    if contains(SessionTimes.Date(dt,:),char(Table.Date)) && contains(SessionTimes.Game_Number(dt,:),'1')
                        if datetime(SessionTimes.Video_2_Start(dt,:)) > datetime(char(Table.Actual_Time))
                            inputName = strcat(File_Structure(1).folder,'\',File_Structure(1).name);
                            break
                        else
                            inputName = strcat(File_Structure(2).folder,'\',File_Structure(2).name);
                            break
                        end
                    end
                elseif contains(Table.Game_Number,'2')
                    if contains(SessionTimes.Date(dt,:),char(Table.Date)) && contains(SessionTimes.Game_Number(dt,:),'2')
                        if datetime(SessionTimes.Video_2_Start(dt,:)) > datetime(char(Table.Actual_Time))
                            inputName = strcat(File_Structure(1).folder,'\',File_Structure(1).name);
                            break
                        else
                            inputName = strcat(File_Structure(2).folder,'\',File_Structure(2).name);
                            break
                        end
                    end
                else
                    error('No Session Times found for video')
                end
            end
            
            outputName = strcat(cd,'\','SingleImpact','.mp4');
            
            a = VideoReader(inputName);
            beginFrame = StartTime * a.FrameRate;
            endFrame = EndTime * a.FrameRate;
            vidObj = VideoWriter(outputName,'MPEG-4'); %#ok<*TNMLP>
            
            a.CurrentTime = beginFrame/a.FrameRate;
            open(vidObj);

            while a.CurrentTime <= endFrame/a.FrameRate
                fprintf('Timestep: %.2f / %.2f\n',a.CurrentTime,EndTime)
                b = readFrame(a);
                writeVideo(vidObj,b)
            end
            
            close(vidObj);
        end

%% End
clc

fprintf('Finished \n')

clearvars -except Table impacts
