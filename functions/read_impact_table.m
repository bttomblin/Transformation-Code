function data = read_impact_table(filename)
%READ_IMPACT_TABLE Loads impact data and adds an impact identification column.
%
%  data = read_impact_table(filename)
%
%  Input:
%     filename -  The path to a .csv file containing impact data.
%
%  Output:
%     data     -  The loaded table with a new, zero-based Impact column.
%                 The Index column is modified so that each impact starts
%                 at zero. The metadata record of each impact is dropped.
%

% This value is hard-coded because it can't be derived from the data.
% Alternatively, this function could be refactored to provide the
% samples/impact as an argument.
samples_per_impact = 283;

data = readtable(filename);

% Add a column with each record's impact number, and renumber the
% indices so that each impact's indices count up from zero.
data.Impact = floor(data.Index / samples_per_impact);
data.Index = mod(data.Index, samples_per_impact);

% Drop the first record of each impact; don't need the
% metadata for this example.
data = data(data.Index > 0, :);

% Renumber the indices so they're 0-based
data.Index = data.Index - 1;

end
