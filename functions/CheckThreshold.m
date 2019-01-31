function CheckThreshold

% This function takes the calibrated impact data and tags the impacts with
% binary variable that denotes whether the impact exceeded the 5g trigger
% threshold (1 = yes, 0 = no).

global impacts

threshold = 5;
for impact=1:length(impacts)
    current_impact = impacts{1,impact};
    idx_zero = find(current_impact.CalibratedData.AccelTime == 0); % finds the trigger index for each impact
    trigger = current_impact.CalibratedData.Accel(idx_zero-13:idx_zero,:);
    
    if ( all((abs(trigger(:,1)) >= threshold)) || all((abs(trigger(:,2)) >= threshold)) || all((abs(trigger(:,3)) >= threshold)))
        impacts{1,impact}.Info.MetThreshold = 1;
    else
        impacts{1,impact}.Info.MetThreshold = 0;
    end
    
end

end