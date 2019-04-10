function ExportImpactsToTable(DataFolders)

if iscell(DataFolders) == 1
    folder = fileparts(DataFolders{1,1});
else
    folder = DataFolders;
end


% potential columns: session type, player ID (diff than MP?), peak to peak,
% team, age, position, film time
impactVarNames = {'MouthpieceID','Date','Time','ImpactNumber','LinAccX','LinAccY','LinAccZ','LinAccRes','RotVelX','RotVelY','RotVelZ','RotVelRes','RotAccX','RotAccY','RotAccZ','RotAccRes'};

load(fullfile(folder,'00_processedData.mat'))

impactTable = {};
for j = 1:length(impacts)
        impactTable(j,:) = {impacts{1,j}.Info.MouthpieceID, impacts{1,j}.Info.ImpactDate, impacts{1,j}.Info.ImpactTime, ...
            impacts{1,j}.Info.ImpactIndex+1, impacts{1,j}.PeakValues.LinAccX, impacts{1,j}.PeakValues.LinAccY, impacts{1,j}.PeakValues.LinAccZ, impacts{1,j}.PeakValues.LinAcc, ... 
            impacts{1,j}.PeakValues.RotVelX,impacts{1,j}.PeakValues.RotVelY,impacts{1,j}.PeakValues.RotVelZ,impacts{1,j}.PeakValues.RotVel,impacts{1,j}.PeakValues.RotAccX, ... 
            impacts{1,j}.PeakValues.RotAccY,impacts{1,j}.PeakValues.RotAccZ,impacts{1,j}.PeakValues.RotAcc};
end

if(~isempty(impactTable))
    dates = impactTable(:,2);
    for i = 1:length(dates)
        temp = cellstr(datetime(dates{i},'InputFormat','yyyyMMdd','Format','MM/dd/yyyy'));
        newDates{i,1} = temp{1};
    end
    impactTable(:,2) = newDates;

    times = impactTable(:,3);
    newTimes=strcat('''',times);
    impactTable(:,3) = newTimes;
    OUTPUT = vertcat(impactVarNames,impactTable);
    
    if(exist(fullfile(folder,strcat('impacts_',impacts{1,1}.Info.ImpactDate,'.xls'))))
    elseif(exist(fullfile(folder,strcat('impacts_',impacts{1,1}.Info.ImpactDate,'-',impacts{1,end}.Info.ImpactDate,'.xls'))))
    elseif(strcmp(impacts{1,1}.Info.ImpactDate, impacts{1,end}.Info.ImpactDate) == 1)
        xlswrite(fullfile(folder,strcat('impacts_',impacts{1,1}.Info.ImpactDate,'.xls')),OUTPUT)
    else
        xlswrite(fullfile(folder,strcat('impacts_',impacts{1,1}.Info.ImpactDate,'-',impacts{1,end}.Info.ImpactDate,'.xls')),OUTPUT)
    end   
    
end
end