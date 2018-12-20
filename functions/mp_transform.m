function trans = mp_transform(rCG, accel, gyro, ang_accel)
% This function will compute the transformation from sensor CG to headform
% CG. Its inputs are rCG, a column vector that points from the sensro CG to the
% headform CG. It can be loaded with read_transformation_info.m or input
% directly. 
% accel: an nx3 matrix of accelerometer data (g) (can be filtered or not, zero
% offset removed or not, etc.) in x, y, z order; 
% gyro: nx3 matrix of gyroscope data (rad/s) (can be filtered or not, zero
% offset removed or not, etc.)
% ang_accel: angular accel data (rad/s/s) in nx3 matrix of x, y, z columns

a = zeros(size(accel));
for i = 1:size(accel, 1)
    lin_accel = accel(i,:)*9.80665; %linear acceleration, in m/s^2
    current_ang_acc = ang_accel(i,:); %x, y, z ang accel for current row
    current_ang_vel = gyro(i,:); %current ang velocity x, y, z
    %find total transformed acceleration in m/s^2
    a(i,:) = lin_accel + cross(current_ang_acc,rCG') + cross(current_ang_vel,cross(current_ang_vel,rCG'));
end
    %convert back to g:
    trans = a./9.80665;
end
