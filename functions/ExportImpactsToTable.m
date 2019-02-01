function ExportImpactsToTable(folder)


% potential columns: session type, player ID (diff than MP?), peak to peak,
% team, age, position, film time
impactVarNames = {'MouthpieceID','Description','Classification','Date','Time','ImpactNumber','LinAccX','LinAccY','LinAccZ','LinAccRes','RotVelX','RotVelY','RotVelZ','RotVelRes','RotAccX','RotAccY','RotAccZ','RotAccRes','MetThreshold'};


load(fullfile(folder,'00_transformedData.mat'))

impactTable = {};
for j = 1:length(impacts)

    if(isfield(impacts{1,j},'PeakValues') && isfield(impacts{1,j},'FilmReview')) % only export events that have been transformed and reviewed

        impactTable(j,:) = {impacts{1,j}.Info.MouthpieceID, impacts{1,j}.FilmReview.ImpactType, impacts{1,j}.FilmReview.ImpactClass, impacts{1,j}.Info.ImpactDate, impacts{1,j}.Info.ImpactTime, ...
            impacts{1,j}.Info.ImpactIndex+1, impacts{1,j}.PeakValues.LinAccX, impacts{1,j}.PeakValues.LinAccY, impacts{1,j}.PeakValues.LinAccZ, impacts{1,j}.PeakValues.LinAcc, ... 
            impacts{1,j}.PeakValues.RotVelX,impacts{1,j}.PeakValues.RotVelY,impacts{1,j}.PeakValues.RotVelZ,impacts{1,j}.PeakValues.RotVel,impacts{1,j}.PeakValues.RotAccX, ... 
            impacts{1,j}.PeakValues.RotAccY,impacts{1,j}.PeakValues.RotAccZ,impacts{1,j}.PeakValues.RotAcc,impacts{1,j}.Info.MetThreshold};

    end
end

if(~isempty(impactTable))
    impactTable = cell2table(impactTable,'VariableNames',impactVarNames);
    impactTable = impactTable(~cellfun(@isempty,impactTable.MouthpieceID),:); % gets rid of empty rows from untransformed impacts
    impactTable.Date = datetime(impactTable.Date,'InputFormat','yyyyMMdd','Format','MM/dd/yyyy');

    if(exist(fullfile(folder,strcat('impacts_',impacts{1,1}.Info.ImpactDate,'.txt'))))
        msg = cell(4,1);
        msg{1,1} = sprintf('Impact export already exists for this date.');
        msg{2,1} = sprintf('%s',impacts{1,1}.Info.ImpactDate);
        msgbox(msg);
    elseif(exist(fullfile(folder,strcat('impacts_',impacts{1,1}.Info.ImpactDate,'-',impacts{1,end}.Info.ImpactDate,'.txt'))))
        msg = cell(4,1);
        msg{1,1} = sprintf('Impact export already exists for this date range.');
        msg{2,1} = sprintf('%s',strcat(impacts{1,1}.Info.ImpactDate,'-',impacts{1,end}.Info.ImpactDate));
        msgbox(msg);
    elseif(strcmp(impacts{1,1}.Info.ImpactDate, impacts{1,end}.Info.ImpactDate) == 1)
        writetable(impactTable,fullfile(folder,strcat('impacts_',impacts{1,1}.Info.ImpactDate,'.txt')))
    else
        writetable(impactTable,fullfile(folder,strcat('impacts_',impacts{1,1}.Info.ImpactDate,'-',impacts{1,end}.Info.ImpactDate,'.txt')))
    end   
    
end
end