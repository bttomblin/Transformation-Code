function PlotData
warning('off')
global DataFolder

temp = strfind(DataFolder,'\');
filenameTemp = DataFolder(temp(end)+1:end);
dirName = fullfile(cd,'functions','plot_temp');
mkdir(dirName);

if exist(fullfile(DataFolder,'01_confirmedImpacts.mat')) == 2
    confirmedImpactsExtracted = 1;
    load(fullfile(DataFolder,'01_confirmedImpacts.mat'));
    impacts = confirmedImpacts;
    filenameOut = strcat('ConfirmedImpacts_',filenameTemp,'.pdf');
else
    confirmedImpactsExtracted = 0;
    load(fullfile(DataFolder,'00_transformedData.mat'));
    filenameOut = strcat('TransformedData_',filenameTemp,'.pdf');
end

if ~exist(fullfile(DataFolder,filenameOut),'file') % only plot data again if file doesn't exist

    cmps = 'XYZ'; cols = {'b','g','r'};
    pp = [483 14 943 951];
    for i = 1:length(impacts)
        filename{i} = fullfile(dirName,strcat('plotTempOut',num2str(i),'.pdf'));
        date0 = impacts{1,i}.Info.ImpactDate;
        year0 = date0(1:4); month0 = date0(5:6); day0 = date0(7:end);
        date = strcat(month0,'-',day0,'-',year0);
        time = impacts{1,i}.Info.ImpactTime;
        index = impacts{1,i}.Info.ImpactIndex;
        mpID = impacts{1,i}.Info.MouthpieceID;
        data = impacts{1,i}.TransformedData;
        t = data.Time;

        figure(i),set(gcf,'visible','off','position',pp),hold on
        for j = 1:3
            subplot(4,3,j*3-2),hold on,title([cmps(j) ' Lin Acc'])
            ylabel('Lin Acc (g)')
            subplot(4,3,j*3-1),hold on,title([cmps(j) ' Rot Vel'])
            ylabel('Rot Vel (rad/s)')
            subplot(4,3,j*3),hold on,title([cmps(j) ' Rot Acc'])
            ylabel('Rot Acc (rad/s^2)')
        end
        subplot(4,3,10),hold on
        ylabel('Lin Acc (g)')
        subplot(4,3,11),hold on
        ylabel('Rot Vel (rad/s)')
        subplot(4,3,12),hold on
        ylabel('Rot Acc (rad/s^2)')

        for j = 1:3
            subplot(4,3,j*3-2)
            plot(t,data.Accel(:,j),'linewidth',2,'color',cols{j})
            yy_la{j} = get(gca,'ylim');
            subplot(4,3,j*3-1)
            plot(t,data.Gyro(:,j),'linewidth',2,'color',cols{j})
            yy_rv{j} = get(gca,'ylim');
            subplot(4,3,j*3)
            plot(t,data.AngAcc(:,j),'linewidth',2,'color',cols{j})
            yy_ra{j} = get(gca,'ylim');
        end
        subplot(4,3,10)
        plot(t,data.AccelRes,'k','linewidth',2)
        xlim([t(1) t(end)])
        subplot(4,3,11)
        plot(t,data.GyroRes,'k','linewidth',2)
        xlim([t(1) t(end)])
        subplot(4,3,12)
        plot(t,data.AngAccRes,'k','linewidth',2)
        xlim([t(1) t(end)])

        yy_la_min = min([yy_la{1}(1) yy_la{2}(1) yy_la{3}(1)]);
        yy_la_max = max([yy_la{1}(2) yy_la{2}(2) yy_la{3}(2)]);
        for j = 1:3:9
            subplot(4,3,j),ylim([yy_la_min yy_la_max])
            xlim([t(1) t(end)])
        end

        yy_rv_min = min([yy_rv{1}(1) yy_rv{2}(1) yy_rv{3}(1)]);
        yy_rv_max = max([yy_rv{1}(2) yy_rv{2}(2) yy_rv{3}(2)]);
        for j = 2:3:9
            subplot(4,3,j),ylim([yy_rv_min yy_rv_max])
            xlim([t(1) t(end)])
        end

        yy_ra_min = min([yy_ra{1}(1) yy_ra{2}(1) yy_ra{3}(1)]);
        yy_ra_max = max([yy_ra{1}(2) yy_ra{2}(2) yy_ra{3}(2)]);
        for j = 3:3:9
            subplot(4,3,j),ylim([yy_ra_min yy_ra_max])
            xlim([t(1) t(end)])
        end

        subplot(4,3,2)
        if confirmedImpactsExtracted == 1
            type = impacts{1,i}.FilmReview.ImpactType;
            title({mpID;['Impact Date: ' date];['Impact Time: ' time];['Impact Index: ' num2str(index)];['Confirmed Impact: ' type];'';'X Rot Vel'})
        else
            title({mpID;['Impact Date: ' date];['Impact Time: ' time];['Impact Index: ' num2str(index)];'';'X Rot Vel'})
        end

        subplot(4,3,10)
        [mm,ii] = max(data.AccelRes);
        plot(t(ii)*ones(1,2),[0 data.AccelRes(ii)],'--','linewidth',1.5,'color',[0.4275    0.4824    0.5451])
        plot(t(ii),data.AccelRes(ii),'p','linewidth',2,'color','c')
        title({'Lin Acc Res';['max: ' num2str(mm,'%.3f') ' g']})

        subplot(4,3,11)
        [mm,ii] = max(data.GyroRes);
        plot(t(ii)*ones(1,2),[0 data.GyroRes(ii)],'--','linewidth',1.5,'color',[0.4275    0.4824    0.5451])
        plot(t(ii),data.GyroRes(ii),'p','linewidth',2,'color','c')
        title({'Rot Vel Res';['max: ' num2str(mm,'%.2f') ' rad/s']})

        subplot(4,3,12)
        [mm,ii] = max(data.AngAccRes);
        plot(t(ii)*ones(1,2),[0 data.AngAccRes(ii)],'--','linewidth',1.5,'color',[0.4275    0.4824    0.5451])
        plot(t(ii),data.AngAccRes(ii),'p','linewidth',2,'color','c')
        title({'Rot Acc Res';['max: ' num2str(mm,'%.1f') ' rad/s^2']})

        for j = 1:12
            subplot(4,3,j)
            xlim([t(1) t(end)])
            xlabel('Time (s)')
        end

        saveas(i,filename{i},'pdf');
    end

    if exist(fullfile(DataFolder,filenameOut)) == 2
        delete(fullfile(DataFolder,filenameOut))
    else end
    append_pdfs(fullfile(DataFolder,filenameOut),filename{:});
    delete(filename{:})
    rmdir(dirName);

    close all
end
end