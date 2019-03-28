function [new_gyro_x, new_gyro_y, new_gyro_z, new_time_x, new_time_y, new_time_z] = mp_remove_duplicates(gyro_data, gyro_time)
%function for removing duplicate gyroscope data points. This function
%removes any values that are exactly the same, assuming that they are
%duplicates and not "real" data, becuase it is unlikely that two
%independent points will have exactly the same value to ~15 decimal
%places. 
%INPUTS: gyro_data - nx3 gyroscope data as column vector of x, y, z.
%        gyro_time - gyroscope timesteps as column vector
%OUTPUTS: new_gyro_x/y/z - column vectors of unique gyro data for
%         corresponding axis (x/y/z will likely be different lengths)
%         new_time_x/y/z - timestamps corresponding to samples kept for
%         each axis

%for finding every different sample. will make vector lengths unequal.
k = 1;
if gyro_data(1,1) == gyro_data(2, 1) 
    new_gyro_x(k) = gyro_data(1, 1);
    i_x(k) = 1;
    k = k+1;
end
for i = 2:length(gyro_data(:,1))-1
    if ((gyro_data(i,1) == gyro_data(i+1, 1)) && (gyro_data(i,1) ~= gyro_data(i-1, 1))) || ((gyro_data(i,1) ~= gyro_data(i+1, 1)) && (gyro_data(i,1) ~= gyro_data(i-1, 1)))
        new_gyro_x(k) = gyro_data(i, 1);
        i_x(k) = i;
        k = k+1;
    end
end
if gyro_data(end,1) ~= gyro_data(end-1, 1) 
    new_gyro_x(k) = gyro_data(end, 1);
    i_x(k) = length(gyro_data(:,1));
    k = k+1;
end
new_gyro_x = new_gyro_x';
new_time_x = gyro_time(i_x);
%y
i=1; k=1;
if gyro_data(1,2) == gyro_data(2, 2) 
    new_gyro_y(k) = gyro_data(1, 2);
    i_y(k) = 1;
    k = k+1;
end
for i = 2:length(gyro_data(:,2))-1
    if ((gyro_data(i,2) == gyro_data(i+1, 2)) && (gyro_data(i,2) ~= gyro_data(i-1, 2))) || ((gyro_data(i,2) ~= gyro_data(i+1, 2)) && (gyro_data(i,2) ~= gyro_data(i-1, 2)))
        new_gyro_y(k) = gyro_data(i, 2);
        i_y(k) = i;
        k = k+1;
    end
end
if gyro_data(end,2) ~= gyro_data(end-1, 2) 
    new_gyro_y(k) = gyro_data(end, 2);
    i_y(k) = length(gyro_data(:,2));
    k = k+1;
end
new_gyro_y = new_gyro_y';
new_time_y = gyro_time(i_y);
%z
i=1; k=1;
if gyro_data(1,3) == gyro_data(2, 3) 
    new_gyro_z(k) = gyro_data(1, 3);
    i_z(k) = 1;
    k = k+1;
end
for i = 2:length(gyro_data(:,3))-1
    if ((gyro_data(i,3) == gyro_data(i+1, 3)) && (gyro_data(i,3) ~= gyro_data(i-1, 3))) || ((gyro_data(i,3) ~= gyro_data(i+1, 3)) && (gyro_data(i,3) ~= gyro_data(i-1, 3)))
        new_gyro_z(k) = gyro_data(i, 3);
        i_z(k) = i;
        k = k+1;
    end
end
if gyro_data(end,3) ~= gyro_data(end-1, 3) 
    new_gyro_z(k) = gyro_data(end, 3);
    i_z(k) = length(gyro_data(:,3));
    k = k+1;
end
new_gyro_z = new_gyro_z';
new_time_z = gyro_time(i_z);


[timeTestX,timeIndsX] = unique(new_time_x);
[timeTestY,timeIndsY] = unique(new_time_y);
[timeTestZ,timeIndsZ] = unique(new_time_z);

if isequal(length(new_time_x),length(timeTestX)) == 0
    new_time_x = timeTestX;
    new_gyro_x = new_gyro_x(timeIndsX);
else end

if isequal(length(new_time_y),length(timeTestY)) == 0
    new_time_y = timeTestY;
    new_gyro_y = new_gyro_y(timeIndsY);
else end

if isequal(length(new_time_z),length(timeTestZ)) == 0
    new_time_z = timeTestZ;
    new_gyro_z = new_gyro_z(timeIndsZ);
else end
   





