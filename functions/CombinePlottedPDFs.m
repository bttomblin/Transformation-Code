function CombinePlottedPDFs(DataFolders)

filenames = {''};

if exist(fullfile(DataFolders{1,1},'01_confirmedImpacts.mat')) == 2
    confirmedImpactsExtracted = 1;
    load(fullfile(DataFolders{1,1},'01_confirmedImpacts.mat'));
    impacts = confirmedImpacts;
    filenameOut = 'ConfirmedImpacts_All.pdf';
    masterLoc = fileparts(DataFolders{1,1});
    
    for i = 1:length(DataFolders)
        currFile = dir(fullfile(DataFolders{1,i},'*.pdf'));
        if strfind(currFile.name,'ConfirmedImpacts') == 1
            currFile = fullfile(DataFolders{1,i},currFile.name);
            filenames = horzcat(filenames,currFile);
        else
        end
        clear('currFile')

    end
    
else
    confirmedImpactsExtracted = 0;
    filenameOut = 'TransformedData_All.pdf';
    masterLoc = fileparts(DataFolders{1,1});
   
    for i = 1:length(DataFolders)
        currFile = dir(fullfile(DataFolders{1,i},'*.pdf'));
        if strfind(currFile.name,'TransformedData') == 1
            currFile = fullfile(DataFolders{1,i},currFile.name);
            filenames = horzcat(filenames,currFile);
        else
        end
        clear('currFile')

    end
end

filenames = filenames(2:end);

if exist(fullfile(masterLoc,filenameOut)) == 2
    delete(fullfile(masterLoc,filenameOut))
else end
append_pdfs(fullfile(masterLoc,filenameOut),filenames{:});


end