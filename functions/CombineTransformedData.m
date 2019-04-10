function CombineTransformedData(DataFolders)

masterLoc = fileparts(DataFolders{1,1});

for i = 1:length(DataFolders)
    ind = strfind(DataFolders{1,i},'\');
    foldername = DataFolders{1,i}(ind(end)+1:end);
    year = strcat('20',foldername(7:8));
    month = foldername(1:2);
    day = foldername(4:5);
    folderDates(i) = str2num(strcat(year,month,day));
end

if exist(fullfile(masterLoc,'00_transformedData.mat')) == 0

impactsAll = [];
dateAll = [];
mpAll = [];
    
for i = 1:length(DataFolders)
    load(fullfile(DataFolders{1,i},'00_transformedData.mat'))
    impactsAll = horzcat(impactsAll,impacts);
    for j = 1:length(impacts)
       mp{j} = impacts{1,j}.Info.MouthpieceID;
       year = impacts{1,j}.Info.ImpactDate(1:4);
       mon = impacts{1,j}.Info.ImpactDate(5:6);
       day = impacts{1,j}.Info.ImpactDate(7:8);
       date{j} = strcat(mon,'-',day,'-',year);  
    end
    
    dateAll = horzcat(dateAll,date);
    mpAll = horzcat(mpAll,mp);
    
    clear('impacts','mp','date')
end

impacts = impactsAll;
outputData = cell2table([mpAll' dateAll']);
outputData = unique(outputData);
outputData = table2cell(outputData);
dates = unique(outputData(:,2));

fprintf('Date         MPs\n');
for i = 1:length(dates)
    inds = ismember(outputData(:,2),dates{i,1});
    inds = find(inds==1);
    mps = outputData{inds(1),1}(3:end);
    if length(inds) > 1
        for jj = 2:length(inds)
            mps = horzcat(mps,strcat(', ',outputData{inds(jj),1}(3:end)));
        end
    else end
    
fprintf('%s   %s\n',dates{i,1},mps);
clear('mps','inds')
end

if length(DataFolders) > 1
    save(fullfile(masterLoc,'00_transformedData.mat'),'impacts')
end

else
    load(fullfile(masterLoc,'00_transformedData.mat'));
    impactsAll = impacts;
    clear('impacts')
    
    for i = 1:length(impactsAll)
        date(i) = str2num(impactsAll{1,i}.Info.ImpactDate);
        time{i} = impactsAll{1,i}.Info.ImpactTime;
        mp(i) = str2num(impactsAll{1,i}.Info.MouthpieceID(3:end));
    end
    dates = unique(date);
    
    for i = 1:length(DataFolders)
        load(fullfile(DataFolders{1,i},'00_transformedData.mat'));
        time1 = impacts{1,1}.Info.ImpactTime;
        tempInd = find(date == folderDates(i));
        tempTime = time(tempInd);
        
        if isempty(strfind(tempTime,time1)) == 1
            impactsAll = horzcat(impactsAll,impacts);
        else
        end
        clear('impacts')
    end
    
    impacts = impactsAll;
    save(fullfile(masterLoc,'00_transformedData.mat'),'impacts')
end

clear('date','time','mp','dates')
if exist(fullfile(DataFolders{1,1},'01_confirmedImpacts.mat')) == 0
confirmedImpactsAll = [];
for i = 1:length(DataFolders)
    if exist(fullfile(DataFolders{1,i},'01_confirmedImpacts.mat')) == 2
        load(fullfile(DataFolders{1,i},'01_confirmedImpacts.mat'))
        confirmedImpactsAll = horzcat(confirmedImpactsAll,confirmedImpacts);
    else end
    clear('confirmedImpacts')
end

confirmedImpacts = confirmedImpactsAll;

save(fullfile(masterLoc,'01_confirmedImpacts.mat'),'confirmedImpacts')
else
    load(fullfile(masterLoc,'01_confirmedImpacts.mat'));
    confirmedImpactsAll = confirmedImpacts;
    clear('confirmedImpacts')
    
    for i = 1:length(confirmedImpactsAll)
        date(i) = str2num(confirmedImpactsAll{1,i}.Info.ImpactDate);
        time{i} = confirmedImpactsAll{1,i}.Info.ImpactTime;
        mp(i) = str2num(confirmedImpactsAll{1,i}.Info.MouthpieceID(3:end));
    end
    dates = unique(date);
    
    for i = 1:length(DataFolders)
        if exist(fullfile(DataFolders{1,i},'01_confirmedImpacts.mat')) == 2
            load(fullfile(DataFolders{1,i},'01_confirmedImpacts.mat'));
            time1 = confirmedImpacts{1,1}.Info.ImpactTime;
            tempInd = find(date == folderDates(i));
            tempTime = time(tempInd);
        
            if isempty(strfind(tempTime,time1)) == 1
                confirmedImpactsAll = horzcat(confirmedImpactsAll,confirmedImpacts);
            else
            end
            clear('confirmedImpacts')
        else end
    end
    
    confirmedImpacts = confirmedImpactsAll;
    save(fullfile(masterLoc,'01_confirmedImpacts.mat'),'confirmedImpacts')
end

end