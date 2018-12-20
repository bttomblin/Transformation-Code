function GetImpactTimes

global DataFolder defaultCalibration estimatedOrientation sport rawFolder baselineFolder calFolder devices timeFolder transformationInfo tFolder impactTimes

for i = 1:length(devices)
    currentFolder = fullfile(rawFolder,devices{i});

    % find all .csv files in folder
    filePattern = fullfile(currentFolder, '*.csv'); 
    theFiles = dir(filePattern);
    
    for j = 1:length(theFiles) % start at 1
        % for each file in each impact location folder
        baseFileName = theFiles(j).name;
        raw_data_file = fullfile(currentFolder,baseFileName);
        
%         %% get impact date from raw data filename
%         date_ind1 = strfind(baseFileName,' - ');
%         date_ind1 = date_ind1(3)+4;
%         date_ind2 = strfind(baseFileName,'.csv')-1;
%         
%         impactDate = strrep(baseFileName(date_ind1:date_ind2);
        
        data = readtable(raw_data_file);

        % This value is hard-coded because it can't be derived from the data.
        % Alternatively, this function could be refactored to provide the
        % samples/impact as an argument.
        IMP_samples_per_impact = 283;

        % Add a column with each record's impact number, and renumber the
        % indices so that each impact's indices count up from zero.
        data.Impact = floor(data.Index/IMP_samples_per_impact)+1;
        data.Index = mod(data.Index,IMP_samples_per_impact);

        % Separate Date timestamps.
        data_date = data(data.Index<1,:);
        date_time = data_date.Timestamp;

        % Converts Epoch datetime to EST datetime
        time_reference = datenum('1970', 'yyyy'); 
        time_date_temp = (time_reference+(date_time-14400)./8.64e4);
        impact_times = datestr(time_date_temp, 'yyyymmdd HH:MM:SS.FFF');
        
        impactTimes.(devices{i}).(strcat('DataCollectionDay',num2str(j))) = impact_times;
    end
    
    
end

end