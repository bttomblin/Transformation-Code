function ExtractConfirmedImpacts

global DataFolders

for i = 1:length(DataFolders)
    load(fullfile(DataFolders{1,i},'00_transformedData.mat'))
    if isfield(impacts{1,1},'FilmReview') == 1
        for j = 1:length(impacts)
            if isfield(impacts{1,j},'FilmReview') == 1 %check each event in case one MP was not reviewed. Stops entire code from breaking
                ImpactClass{j} = impacts{1,j}.FilmReview.ImpactClass;
                ImpactType{j} = impacts{1,j}.FilmReview.ImpactType;
            end
        end
        TP_inds = find(strcmp(ImpactClass,'TP')); 
        confirmedImpacts = impacts(TP_inds);
    else
        TP_inds = [];
    end
    if isempty(TP_inds) == 0
        save(fullfile(DataFolders{1,i},'01_confirmedImpacts.mat'),'confirmedImpacts')
    else end
    clear('impacts','TP_inds','ImpactClass','ImpactType')
end
end