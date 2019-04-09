function CombineTransformedData(DataFolders)

masterLoc = fileparts(DataFolders{1,1});

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

else end

if exist(fullfile(DataFolders{1,1},'01_confirmedImpacts.mat')) == 2
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
else end

end