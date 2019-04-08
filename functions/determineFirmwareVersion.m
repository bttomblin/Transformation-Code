function numMetaDataLines = determineFirmwareVersion(currentFile)

data = readtable(currentFile);
temp = data.Timestamp;

indsTimestamp = find(temp>1e9);
indsMode = find(temp<-8.6e7);

if indsTimestamp(1) == 2
    numMetaDataLines = 2;
else
    numMetaDataLines = 1;
end

end