function impact_times = get_impact_time(raw_data_filename)

data = readtable(raw_data_filename);

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

end