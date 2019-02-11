function CombinePFN(DataFolders)

masterLoc = fileparts(DataFolders{1,1});

PFN_all = {};
for i = 1:length(DataFolders)
    load(fullfile(DataFolders{1,i},'01_PFN.mat'))
      
    if(isempty(PFN_all))
        PFN_all = PFN;
    else
        PFN_all = outerjoin(PFN_all,PFN,'MergeKeys',true);
    end    
end

save(fullfile(masterLoc,'01_PFN.mat'), 'PFN_all');
writetable(PFN_all,fullfile(masterLoc,'PFN.txt'));

end