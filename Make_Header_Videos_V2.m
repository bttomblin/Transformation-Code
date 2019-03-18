close all
clear
clc

PreImpactTime = 3;
PostImpactTime = 3;

% Name of impact as string
impactname = 'Header';

% Name if impact for Video Files (no spaces)
impactvideo = 'Header';

% Path to transformed data
Path = '\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\Merged_Analysis\Fall2018_Merged_transformedData.mat';

%% Load and make new impact list

load(Path);

ii = 1;
for i = 1:length(impacts)
   if isequal(impacts{1,i}.FilmReview.ImpactType,impactname)
       Impact_List{ii,1} = impacts{1,i};
       OI_List{ii,1} = i;
       ii = ii+1;
   end
end

%% Make New Directory
folderpath = strcat(cd,'\','Video_Outputs','\',impactvideo);
mkdir(folderpath)

%% Make Table of Impacts

for count1 = 1:length(Impact_List)
    % Head counter
        if count1 < 10
            Label_List{count1,1} = sprintf('Header_00%d',count1);
        elseif count1 < 100
            Label_List{count1,1} = sprintf('Header_0%d',count1);
        else
            Label_List{count1,1} = sprintf('Header_%d',count1);
        end
    % MP
        MP_List{count1,1} = Impact_List{count1,1}.FilmReview.MouthpieceID;
    % Date
        Date = Impact_List{count1,1}.FilmReview.ImpactDate;
            if ~contains(Date,'Game')
                t = datetime(Date,'InputFormat','MMM_dd_yy');
                s = datetime(t,'Format','yyyy-MM-dd');
                Date_List{count1,1} = char(s);
                Game_List{count1,1} = 'No Game Number';
            else
                g = strfind(Date,'Game');
                    Game_List{count1,1} = Date(g:g+4);
                    Date = strcat(Date(1:g-1),Date(length(Date)-1:length(Date)));
                t = datetime(Date,'InputFormat','MMM_dd_yy');
                s = datetime(t,'Format','yyyy-MM-dd');
                Date_List{count1,1} = char(s);
            end
    % Impact Number
        I_List{count1,1} = Headers{count1,1}.FilmReview.ImpactNumber;        
    % Actual Time
        ATList{count1,1} = char(Impact_List{count1,1}.FilmReview.VideoImpactTime);
    % Video Time
        VTList{count1,1} = char(Impact_List{count1,1}.FilmReview.FilmTime);
end

Table = table(Label_List,MP_List,Date_List,Game_List,I_List,VTList,ATList,OI_List,'VariableNames',...
    {'Video_Label' 'MP' 'Date' 'Game_Number' 'Impact_Number' 'Video_Time' 'Actual_Time' 'Total_Impact_Number'});

xlsxname = strcat(impactvideo,'_Index_List.xlsx');
writetable(Table,xlsxname);

%% Make new videos
Output_Video_Folder = '\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\Header_Videos';
cd(Output_Video_Folder);

for header_count = 1:height(Header_Table)
    % Find Video Folder based on MP Team
        if contains(Header_Table.MP(header_count,1),'092') || contains(Header_Table.MP(header_count,1),'093') || contains(Header_Table.MP(header_count,1),'103') || contains(Header_Table.MP(header_count,1),'110')
            if contains(Header_Table.Game_Number(header_count,1),'No')
                VideoFolder = strcat('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\2018_Fall_U14\Film_Review\',char(Header_Table.Date(header_count,1)));
                    addpath(VideoFolder)
            else
                VideoFolder = strcat('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\2018_Fall_U14\Film_Review\',char(Header_Table.Date(header_count,1)),'_',char(Header_Table.Game_Number(header_count,1)));
                    addpath(VideoFolder)
            end
        else
            if contains(Header_Table.Game_Number(header_count,1),'No')
                VideoFolder = strcat('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\2018_Fall_U16\Film_Review\',char(Header_Table.Date(header_count,1)));
                    addpath(VideoFolder)
            else
                VideoFolder = strcat('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\2018_Fall_U16\Film_Review\',char(Header_Table.Date(header_count,1)),'_',char(Header_Table.Game_Number(header_count,1)));
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
        VideoTime = char(Header_Table.Video_Time(header_count,1));
            VT_1 = duration(VideoTime,'InputFormat','hh:mm:ss');
            VT_2 = seconds(VT_1);
            StartTime = VT_2 - PreImpactTime;
            EndTime = VT_2 + PostImpactTime;
    
    % Make Videos
        % If only 1 video on that day
        if length(File_Structure) == 1
            clc;
            fprintf('Making Video for Header: %d/%d\n',header_count,height(Header_Table))
            
            inputName = strcat(File_Structure.folder,'\',File_Structure.name);
            outputName = strcat(Output_Video_Folder,'\',char(Header_Table.Header_Number(header_count,1)),'.mp4');
            
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
                if contains(Header_Table.MP(header_count,1),'092') || contains(Header_Table.MP(header_count,1),'093') || contains(Header_Table.MP(header_count,1),'103') || contains(Header_Table.MP(header_count,1),'110')
                    SessionTimes = readtable('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\U14_Session_Times.xlsx');
                        SessionTimes.Video_2_Start = datestr(SessionTimes.Video_2_Start,'HH:MM:SS');
                        SessionTimes.Date = datestr(SessionTimes.Date,'yyyy-mm-dd');
                else
                    SessionTimes = readtable('\\medctr\DFS\cib$\shared\02_projects\mouthpiece_data_collection\soccer\2018_Soccer_Fall\U16_Session_Times.xlsx');
                        SessionTimes.Video_2_Start = datestr(SessionTimes.Video_2_Start,'HH:MM:SS');
                        SessionTimes.Date = datestr(SessionTimes.Date,'yyyy-mm-dd');
                end
            
            fprintf('Making Video for Header: %d/%d\n',header_count,height(Header_Table))
            
            for dt = 1:height(SessionTimes)
                if contains(Header_Table.Game_Number(header_count,:),'No')
                    if contains(SessionTimes.Date(dt,:),char(Header_Table.Date(header_count,:)))
                        if datetime(SessionTimes.Video_2_Start(dt,:)) > datetime(char(Header_Table.Actual_Time(header_count,1)))
                            inputName = strcat(File_Structure(1).folder,'\',File_Structure(1).name);
                            break
                        else
                            inputName = strcat(File_Structure(2).folder,'\',File_Structure(2).name);
                            break
                        end
                    end
                elseif contains(Header_Table.Game_Number(header_count,:),'1')
                    if contains(SessionTimes.Date(dt,:),char(Header_Table.Date(header_count,:))) && contains(SessionTimes.Game_Number(dt,:),'1')
                        if datetime(SessionTimes.Video_2_Start(dt,:)) > datetime(char(Header_Table.Actual_Time(header_count,1)))
                            inputName = strcat(File_Structure(1).folder,'\',File_Structure(1).name);
                            break
                        else
                            inputName = strcat(File_Structure(2).folder,'\',File_Structure(2).name);
                            break
                        end
                    end
                elseif contains(Header_Table.Game_Number(header_count,:),'2')
                    if contains(SessionTimes.Date(dt,:),char(Header_Table.Date(header_count,:))) && contains(SessionTimes.Game_Number(dt,:),'2')
                        if datetime(SessionTimes.Video_2_Start(dt,:)) > datetime(char(Header_Table.Actual_Time(header_count,1)))
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
            
            outputName = strcat(Output_Video_Folder,'\',char(Header_Table.Header_Number(header_count,1)),'.mp4');
            
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
end

cd(orig_dir);