function [Time_Differences] = CALC_TIME_DIFF(Title_initial,Time_Date_Full,VideoStartTime)

if isempty(Time_Date_Full) == 0
% Separates time from Time_Date and Video Start Time\
    [r,~] = size(VideoStartTime);
        if r == 1
            H_Video = VideoStartTime(1,(1:2));
            Mn_Video = VideoStartTime(1,(4:5));
            S_Video = VideoStartTime(1,(7:8));
        elseif r == 2
            H_Video1 = VideoStartTime(1,(1:2));
            Mn_Video1 = VideoStartTime(1,(4:5));
            S_Video1 = VideoStartTime(1,(7:8));
            H_Video2 = VideoStartTime(2,(1:2));
            Mn_Video2 = VideoStartTime(2,(4:5));
            S_Video2 = VideoStartTime(2,(7:8));
        else
            error('Only 2 video start times usable in this version of the code')
        end

    [q,~] = size(Time_Date_Full);
    
    for t = 1:q
        Y(t,:) = Time_Date_Full(t,(1:4));
        M(t,:) = Time_Date_Full(t,(5:6));
        D(t,:) = Time_Date_Full(t,(7:8));
        H_MP(t,:) = Time_Date_Full(t,(10:11));
        Mn_MP(t,:) = Time_Date_Full(t,(13:14));
        S_MP(t,:) = Time_Date_Full(t,(16:17));
        
        MP_Time(t,:) = datetime([Y(t,:)  M(t,:)  D(t,:)  H_MP(t,:)  Mn_MP(t,:)  S_MP(t,:)],'InputFormat','yyyyMMddHHmmss');
    end

        if r == 1
             Video_Time = datetime([Y(1,:)  M(1,:)  D(1,:)  H_Video  Mn_Video  S_Video],'InputFormat','yyyyMMddHHmmss');
        else
             Video_Time1 = datetime([Y(1,:)  M(1,:)  D(1,:)  H_Video1  Mn_Video1  S_Video1],'InputFormat','yyyyMMddHHmmss');
             Video_Time2 = datetime([Y(1,:)  M(1,:)  D(1,:)  H_Video2  Mn_Video2  S_Video2],'InputFormat','yyyyMMddHHmmss');
        end
    
% Calculate difference in the event time and the video start time
    Time_Diff_1 = [];
    Time_Diff_2 = [];

    if r == 1
        Time_Diff = string(MP_Time-Video_Time);
    else
        Time_Counter1 = 1;
        Time_Counter2 = 1;
        for u = 1:q
            if Video_Time2 > MP_Time(u,:)
                if isempty(Time_Diff_1) == 1
                    clear Time_Diff_1
                end

                Time_Diff_1(Time_Counter1,:) = string(MP_Time(u,:)-Video_Time1);
                Time_Counter1 = Time_Counter1 +1;
            else
                if isempty(Time_Diff_2) == 1
                    clear Time_Diff_2
                end
                
                Time_Diff_2(Time_Counter2,:) = string(MP_Time(u,:)-Video_Time2);
                Time_Counter2 = Time_Counter2 + 1;
            end
        end
    end

% Create matrix of MP-Video Time Difference

    ind_Space = strfind(Title_initial," ");
    ind_MP = strfind(Title_initial,"MP");
        MP_name = string(Title_initial(ind_MP(1,1)+2:ind_Space(1,1)-1));

    if r == 1
        Time_Differences = vertcat(MP_name,Time_Diff);
    else
        Session1 = "Video_1";
        Session2 = "Video_2";
        
        if isempty(Time_Diff_1) == 1
            Time_Differences = vertcat(MP_name,Session2,Time_Diff_2);
        elseif isempty(Time_Diff_2) == 1
            Time_Differences = vertcat(MP_name,Session1,Time_Diff_1);
        else
            Time_Differences = vertcat(MP_name,Session1,Time_Diff_1,Session2,Time_Diff_2);
        end

    end
        
else
    Time_Differences = 'No Real Impacts';
end
    
end