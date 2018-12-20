function aa = mp_angular_accel(time, data)
%This function calculates the angular acceleration of the mouthpiece based
%on a numerical differentiation of gyroscope readings. TIME is a column
%vector of timesteps of data. If the gyroscope data has been in
%interpolated to correspond to accelerometer readings, TIME should be the
%timesteps used to interpolate the data. DATA is a nx3 matrix whose columns
%contain x, y, and z gyroscope data Specifically, the finite difference
%method is used to approximate the derivative. If the data is not filtered
%before this step, large amounts of noise will be found in the angular
%acceleration, as the numerical differentiation amplifies any noise present
%in the signal. See dt_order_4_or_five_point_stencil.m for the numerical
%differentiaion details.
aa = zeros(size(data));
for i = 1:size(data, 2)
    current_data = data(:,i)';
    current_accel = dt_order_4_or_five_point_stencil(time', current_data);
    aa(:,i) = current_accel';
end

end