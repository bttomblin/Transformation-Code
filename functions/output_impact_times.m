function [] = output_impact_times(time_folder, raw_folder, file, date_and_time)

[~, low] = fileparts(raw_folder);

saveFolder = fullfile(time_folder, low);

if~(7==exist(saveFolder,'dir'))
    mkdir(saveFolder)
end

date_time_cell = cellstr(date_and_time);

date_time_table = table(date_time_cell, 'VariableNames', {'Date_and_Time'});

writetable(date_time_table, strcat(saveFolder, '\', file(1:end-4), ' - Impact Times.csv'));

