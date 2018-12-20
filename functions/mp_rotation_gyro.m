function rot = mp_rotation_gyro(gyro_matrix, data)
%this function rotates gyroscope data onto anatomical axes. The data
%should be formatted as columns of x, y, and z sensor readings. 
%The gyro_matrix input is a rotation matrix oriented such that the
%columns of the matrix are unit vectors to rotate the x, y and z sensor axes 
%(in that order) to the desired CS. This can be read from a file (see
%read_transformation_info.m) or input directly.
if size(data, 2) ~= 3
    error('Data can only contain three columns of x, y, and z readings')
end
rot = zeros(size(data));
%for each row, rotate x, y and z
%the transformation matrix is formatted to rotate column vector of [x;y;z],
%so the row vector of data is transposed. The rotation matrix must be on
%the left of the multiplication and the data to be rotated on the right.
for i = 1:size(data, 1)
    rot(i, :) = gyro_matrix*data(i,:)';
end


