function [data, meta] = read_impact_table_variable(filename)
%READ_IMPACT_TABLE Loads impact data and adds an impact identification column.
%
%  data = read_impact_table(filename)
%
%  Input:
%     filename -  The path to a .csv file containing impact data.
%
%  Outputs:
%     data     -  The loaded table with a new, zero-based Impact column.
%                 The Index column is modified so that each impact starts
%                 at zero. The metadata record of each impact is dropped.
%     meta     -  Metadata stored during test, including capture mode used,
%                 number of samples collected, and sample rate. If impact mode was
%                 used, mode = 1 and the pre and post impact samples are reported. If
%                 interval mode was used, mode = 2 and only total number of samples
%                 collected are reported.
%

data = readtable(filename);

%determine if impact or interval mode was used to collect data
%Timestamp in first metadata row contains this information in 4-byte
%structure:
capture_mode = bitand(bitshift(data.Timestamp(1), -16, 'int32'), 65535, 'int32');
%calculate sample rate from tick interval input (65536/tick), stored in
%GyroX
sample_rate = 65536/data.GyroX(1);

if capture_mode == 64222 %this corresponds to impact mode
    %for impact mode, include pre impact samples (stored in AccelY)
    %add two for two meta-data samples per impact collected
    samples_per_impact = data.AccelZ(1)+2+data.AccelY(1);
    mode = 1;
    %store metdata in a table so it can be accessed later,
    %since it will not be stored in impact table ("data")
    meta = table(mode, data.AccelY(1), data.AccelZ(1), sample_rate,...
        'VariableNames', {'CaptureMode', 'PreSamples', 'PostSamples', 'SampleRate'});
elseif capture_mode == 47838 %this corresponds to interval mode
    %interval mode, number of samples stored in AccelZ.
    samples_per_impact = data.AccelZ(1)+2;
    mode = 2;
    %store metdata in a table so it can be accessed later,
    %since it will not be stored in impact table ("data")
    meta = table(mode,  data.AccelZ(1), sample_rate,...
        'VariableNames', {'CaptureMode', 'Samples', 'SampleRate'});
else 
    error('Data collection mode not recognized');
end
% Add a column with each record's impact number, and renumber the
% indices so that each impact's indices count up from zero.
data.Impact = floor(data.Index / samples_per_impact);
data.Index = mod(data.Index, samples_per_impact);

% Drop the first and second record of each impact; don't need the
% metadata for this example.
data = data(data.Index > 1, :);

% Renumber the indices so they're 0-based
data.Index = data.Index - 1;

end
