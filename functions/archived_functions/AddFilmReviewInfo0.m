function AddFilmReviewInfo

global DataFolders

for i = 1:length(DataFolders)
    load(fullfile(DataFolders{1,i},'00_transformedData.mat'))
    for j = 1:length(impacts)
        ImpactClass{j} = impacts{1,j}.FilmReview.ImpactClass;
        ImpactType{j} = impacts{1,j}.FilmReview.ImpactType;
    end
    TP_inds = find(strcmp(ImpactClass,'TP')); 
    confirmedImpacts = impacts(TP_inds);
    
    if isempty(TP_inds) == 0
        save(fullfile(DataFolders{1,i},'01_confirmedImpacts.mat'),'confirmedImpacts')
    else end
    clear('impacts','TP_inds','ImpactClass','ImpactType')
end
end