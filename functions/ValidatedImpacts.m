function AddFilmReviewInfo

MONTHS = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

global DataFolders

% find Film Review folder
masterLoc = fileparts(DataFolders{1,1});

test = dir(fullfile(masterLoc,'*Film_Review'));

while isempty(test) == 1
    masterLoc = fileparts(masterLoc);
    test = dir(fullfile(masterLoc,'*Film_Review'));
end
    
filmReviewFolder = fullfile(masterLoc,'Film_Review');
files = dir(fullfile(filmReviewFolder,'*.mat'));
load(fullfile(filmReviewFolder,files(1,1).name))

for i = 1:length(DataFolders)
    tempInds=strfind(DataFolders{1,i},'\');
    currFolder = DataFolders{1,i}(tempInds(end)+1:end);
    
    load(fullfile(DataFolders{1,i},'00_transformedData.mat'))
    for j = 1:length(impacts)
        date{j} = impacts{1,j}.Info.ImpactDate;
    end
    
    uniqueDates = unique(date);
    
    if length(uniqueDates) == 1
        year = impacts{1,1}.Info.ImpactDate(1:4);
        mon = impacts{1,1}.Info.ImpactDate(5:6);
        day = impacts{1,1}.Info.ImpactDate(7:8);

        if isempty(strfind(currFolder,'Game')) == 1
            filmReviewFieldname = strcat(MONTHS{str2num(mon)},'_',day,'_',year(3:4));    
        else
            tempInds = strfind(currFolder,'Game');
            tempGame = currFolder(tempInds:tempInds+4);
            filmReviewFieldname = strcat(MONTHS{str2num(mon)},'_',day,'_',year(3:4));    
            filmReviewFieldname = strcat(filmReviewFieldname(1:7),tempGame,'_',filmReviewFieldname(8:end));
        end
        
        mps = {};
        for j = 1:length(impacts)
            mps{j} = impacts{1,j}.Info.MouthpieceID;
        end

        mp = unique(mps);    
        for m = 1:length(mp)
            if isfield(FILM_REVIEW,filmReviewFieldname) == 0
                msg = cell(4,1);
                msg{1,1} = sprintf('ERROR: No video analysis in film review .mat structure for current date.');
                msg{2,1} = sprintf('%s',strrep(filmReviewFieldname,'_','-'));
                errordlg(msg);
                break;
            elseif isfield(FILM_REVIEW.(filmReviewFieldname),mp{m}) == 0
                msg = cell(4,1);
                msg{1,1} = sprintf('ERROR: No video analysis in film review .mat structure for this MP on current date.');
                msg{2,1} = sprintf('%s, %s',mp{m},strrep(filmReviewFieldname,'_','-'));
                errordlg(msg);
            else
                filmReviewInfo = FILM_REVIEW.(filmReviewFieldname).(mp{m});

                inds = ismember(mps,mp{m});
                inds = find(inds==1);

                if length(inds) ~= length(filmReviewInfo.Impact_Number(filmReviewInfo.Impact_Number ~= 0))
                        msg = cell(4,1);
                        msg{1,1} = sprintf('ERROR: Number of transformed impacts does not match number in film review');
                        msg{2,1} = sprintf('%s, %s',mp{m},strrep(filmReviewFieldname,'_','-'));
                        msg{3,1} = sprintf('# transformed: %s',num2str(length(inds)));
                        msg{4,1} = sprintf('# reviewed: %s',num2str(length(filmReviewInfo.Impact_Number(filmReviewInfo.Impact_Number ~= 0))));
                        errordlg(msg);
                else 
                    
                    for j = 1:height(filmReviewInfo)
                        if (filmReviewInfo.Impact_Number(j) > 0)
                            impacts{1,inds(filmReviewInfo.Impact_Number(j))}.FilmReview.MouthpieceID = impacts{1,inds(filmReviewInfo.Impact_Number(j))}.Info.MouthpieceID;
                            impacts{1,inds(filmReviewInfo.Impact_Number(j))}.FilmReview.ImpactDate = filmReviewFieldname;
                            impacts{1,inds(filmReviewInfo.Impact_Number(j))}.FilmReview.MouthpieceImpactTime = impacts{1,inds(filmReviewInfo.Impact_Number(j))}.Info.ImpactTime;
                            impacts{1,inds(filmReviewInfo.Impact_Number(j))}.FilmReview.ImpactNumber = filmReviewInfo.Impact_Number(j);
                            impacts{1,inds(filmReviewInfo.Impact_Number(j))}.FilmReview.VideoImpactTime = filmReviewInfo.Impact_Time(j);
                            impacts{1,inds(filmReviewInfo.Impact_Number(j))}.FilmReview.FilmTime = filmReviewInfo.Film_Time(j);
                            impacts{1,inds(filmReviewInfo.Impact_Number(j))}.FilmReview.ImpactType = filmReviewInfo.Impact_Type{j};
                            impacts{1,inds(filmReviewInfo.Impact_Number(j))}.FilmReview.ImpactClass = filmReviewInfo.Impact_Class{j};
                        end
                    end
                end
            end
        end
    save(fullfile(DataFolders{1,i},'00_transformedData.mat'),'impacts')
    ExportImpactsToTable(DataFolders{1,i})
    ExportPFN(filmReviewFolder, filmReviewFieldname,DataFolders{1,i})
    
    else
        msg = cell(2,1);
        msg{1,1} = sprintf('WARNING: Folder(s) contain impacts from more than 1 date.');
        msg{2,1} = sprintf('Ability to add film review analysis to transformed data has not been implemented for saving MP data from >1 day per folder');
        errordlg(msg);
    end
    clear('date')
end

end