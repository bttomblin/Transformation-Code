function voltage = getvoltage(filename)

data = readtable(filename);
data = data(mod(data.Index,283) == 0, :);
voltage = round(data.AccelX./256,3);

end