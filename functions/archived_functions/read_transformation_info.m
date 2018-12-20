function [r_cg, r_accel, r_gyro] = read_transformation_info(transformation_file)
%This function reads a file containing head CG and rotation matrix data.
%
%The file must have the following information in columns in this order:
%
%1. Vector describing the distance from head CG to sensor CG in milimeters
%(labeled "sensorCG") 2. Unit vector to rotate x-axis of sensor to global
%CS (labeled "X") 3. Unit vector to rotate y-axis of sensor to global CS
%(labeled "Y") 4. Unit vector to rotate z-axis of sensor to global CS
%(labeled "Z")
%
%This is an example of how the file should be formated to be compatible
%with this code:
%
% headCG       X         Y          Z
%   63.4      0.998    0.0316     0.0544
% -11.76     0.0103    0.7706    -0.6372 
% -68.08    -0.0602    0.6365     0.7688  
%
%This function outputs three matrices: accelerometer rotation matrix,
%gyroscope rotation matrix, and position vector from mouthpiece to headform
%CG (in that order). The rotation matrices can be used to rotate sensor
%data (see the function mp_rotation for more information). There is one
%rotation matrix for the gyroscope and one for the accelerometer, due to
%the fact that they are mounted in different orientations on the circuit
%board. Their distance from the head CG is assumed to be the same because
%the distance between them is small relative to their distance from the CG.

info = readtable(transformation_file);
sensorCG = info.sensorCG;
headCG = [0; 0; 0];
sensor_to_head = headCG - sensorCG;
r_cg = sensor_to_head*1/1000;

ux = info.X;
uy = info.Y;
uz = info.Z;

% Accelerometer orientation
x1 = ux;
y1 = uy;
z1 = uz;
r_accel = [x1, y1, z1];
% Gyro orientation: gyro x is accel -y. gyro y is accel x. 
%This was determined for rev 3 boards based on how the gyro and accel
%are oriented relative to each other. 
x2 = -uy;
y2 = ux;
z2 = uz;
r_gyro = [x2, y2, z2];
end