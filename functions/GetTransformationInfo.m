function GetTransformationInfo

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

global estimatedProjection estimatedOrientation sport devices transformationInfo impacts

transformInfoFolder = fullfile(cd,'01_MP_values',sport);

for i = 1:length(devices)
    transformation_file = fullfile(transformInfoFolder,strcat(devices{i},'_Transform.xlsx'));
    if(~exist(transformation_file))
        msg = cell(4,1);
        msg{1,1} = sprintf('ERROR: No transformation file exists for this MP. All impacts from the MP will be excluded from the transformation step on this date.');
        msg{2,1} = sprintf('%s, %s',devices{i}, impacts{1,1}.Info.ImpactDate);
        errordlg(msg);
    else
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

        transformationInfo.(devices{i}).r_cg = r_cg;
        transformationInfo.(devices{i}).r_accel = r_accel;
        transformationInfo.(devices{i}).r_gyro = r_gyro;
    end
end

for k = 1:length(impacts)
    MP = impacts{1,k}.Info.MouthpieceID;
    if(isfield(transformationInfo,MP))
        impacts{1,k}.Info.Transformation.RotationMatrix_Accel = transformationInfo.(MP).r_accel;
        impacts{1,k}.Info.Transformation.RotationMatrix_Gyro = transformationInfo.(MP).r_gyro;
        impacts{1,k}.Info.Transformation.ProjectionVector = transformationInfo.(MP).r_cg;
    end
end

if estimatedProjection == 1
    
    r_cg = [-0.0471;    0.0115;    0.0764];
    
    for i = 1:length(devices)
        impacts{1,k}.Info.Transformation.ProjectionVector = transformationInfo.(MP).r_cg;
    end
    
    
elseif estimatedOrientation == 1
    
    X = 45;
    Y = 175; 
    Z = 165;
    
    DCM = [cosd(-Y) 0 -sind(-Y);0 1 0; sind(-Y) 0 cosd(-Y)]*[1 0 0;0 cosd(-X) sind(-X); 0 -sind(-X) cosd(-X)]*[cosd(-Z) sind(-Z) 0;-sind(-Z) cosd(-Z) 0; 0 0 1];
    r_accel = DCM';
    
    r_gyro = [-r_accel(:,2) r_accel(:,1) -r_accel(:,3)];
    
    for i = 1:length(devices)
        impacts{1,k}.Info.Transformation.RotationMatrix_Accel = transformationInfo.(MP).r_accel;
        impacts{1,k}.Info.Transformation.RotationMatrix_Gyro = transformationInfo.(MP).r_gyro;
    end

    
else
end

a = 10;

end