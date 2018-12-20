function ExtractDeviceIDs_and_ImpactDates

global DataFolder devices

files = dir(fullfile(DataFolder,'*.csv'));

for i = 1:length(files)
    ind = strfind(files(i).name,' ');
    device{i} = files(i).name(1:ind(1)-1);
end

devices = unique(device);

end