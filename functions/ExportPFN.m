function ExportPFN(filmReviewFolder, filmReviewFieldname, outFolder)

files = dir(fullfile(filmReviewFolder,'*.mat'));
load(fullfile(filmReviewFolder,files(1,1).name));
dateFR = FILM_REVIEW.(filmReviewFieldname);

mps = fields(dateFR);
if(contains(filmReviewFieldname,'Game'))
    tempstr = strsplit(filmReviewFieldname, '_');
    date = strcat(tempstr(1),'_',tempstr(2),'_',tempstr(4));
    date = string(datestr(date,'mm/dd/yy'));
    outdate = datestr(date,'yyyymmdd');
else
    date = string(datestr(filmReviewFieldname,'mm/dd/yy'));
    outdate = datestr(filmReviewFieldname,'yyyymmdd');
end

PFN = {};

for i=1:length(mps)
    MouthpieceID = string(mps{i});
    currMP = dateFR.(mps{i});
    if(any(strcmp(currMP.Impact_Class,"PFN")))
        temp = currMP(strcmp(currMP.Impact_Class,"PFN"),2:4);
        temp = addvars(temp,repmat(MouthpieceID,height(temp),1),'Before','Impact_Type');
        temp = addvars(temp,repmat(date,height(temp),1),'Before','Film_Time');
        
        temp.Properties.VariableNames('Var1') = "MouthpieceID";
        temp.Properties.VariableNames('Var3') = "Date";
        temp.Properties.VariableNames('Impact_Type') = "Description";
        temp.Properties.VariableNames('Film_Time') = "FilmTime";
        temp.Properties.VariableNames('Impact_Time') = "Time";
        temp = temp(:,[1:3,5,4]);
        
        if(isempty(PFN))
            PFN = temp;
        else
            PFN = outerjoin(PFN,temp,'MergeKeys',true);
        end    
    end
end

save(fullfile(outFolder,'01_PFN.mat'), 'PFN');

end

