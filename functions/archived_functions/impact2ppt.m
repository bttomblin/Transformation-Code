function [] = impact2ppt(impact_info, impact_data)

to_ppt_folder = fullfile(pwd,'functions', 'toPPT_File');
figure(1)
imshow(fullfile(to_ppt_folder,'Legend.jpg'));

title = sprintf('%s - %s (%s) - %s - Impact #%d',impact_info.MP, strrep(impact_info.Date,'.','/'), strrep(impact_info.Time,'.',':'), impact_info.Type, impact_info.Number);

figure(2)

subplot(2,2,1)
    plot(impact_data.Time*1000,impact_data.AccelX,'Color',[0, 0.4470, 0.7410])
    hold on
    plot(impact_data.Time*1000,impact_data.AccelY,'Color',[0.8500, 0.3250, 0.0980])
    plot(impact_data.Time*1000,impact_data.AccelZ,'Color',[0.9290, 0.6940, 0.1250])
    hold off
    ylabel('Linear Acceleration (g)')
    xlabel('Time (ms)')
    grid on
    grid minor
    xlim([-15 45]);

subplot(2,2,3)
    plot(impact_data.Time*1000, sqrt(impact_data.AccelX.^2+impact_data.AccelY.^2+impact_data.AccelZ.^2), 'color','k')
    ylabel('Linear Resultant Acceleration (g)')
    xlabel('Time (ms)')
    grid on
    grid minor
    xlim([-15 45]);

subplot(2,2,2)
    plot(impact_data.Time*1000,impact_data.GyroX,'Color',[0, 0.4470, 0.7410])
    hold on
    plot(impact_data.Time*1000,impact_data.GyroY,'Color',[0.8500, 0.3250, 0.0980])
    plot(impact_data.Time*1000,impact_data.GyroZ,'Color',[0.9290, 0.6940, 0.1250])
    hold off
    ylabel('Angular Velocity (rad/s)')
    xlabel('Time (ms)')
    xlim([-15 45]);
    grid on
    grid minor

subplot(2,2,4)
    plot(impact_data.Time*1000, sqrt(impact_data.GyroX.^2+impact_data.GyroY.^2+impact_data.GyroZ.^2), 'color','k')
    ylabel('Resultant Angular Velocity (rad/s)')
    xlabel('Time (ms)')
    xlim([-15 45]);
    grid on
    grid minor
    
% This creates a centered title over the subplots
delete(findall(gcf,'type','annotation'))
slide_title = annotation('textbox', [0 0.9 1 0.1], 'String', title,'EdgeColor', 'none','HorizontalAlignment', 'center');
slide_title.FontSize = 16;
slide_title.FontName = 'Times New Roman';

toPPT(figure(1),'SlideNumber','append','Height',50,'Width',90,'pos','NW','gapN',-60,'gapWE',-375);
toPPT(figure(2),'SlideNumber','current','gapN',60,'Height%',120,'Width%',80)
