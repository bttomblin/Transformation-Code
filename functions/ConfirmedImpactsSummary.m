function ConfirmedImpactsSummary

global DataFolders

masterLoc = fileparts(DataFolders{1,1});
filename = '01_confirmedImpacts.mat';
filenameOut = 'confirmedImpactsSummary';

if exist(fullfile(masterLoc,filename)) == 2
    load(fullfile(masterLoc,filename));
    
    num = length(confirmedImpacts);
    
    for i = 1:num
        mp{i} = confirmedImpacts{1,i}.Info.MouthpieceID;
        date{i} = confirmedImpacts{1,i}.Info.ImpactDate;
        type{i} = confirmedImpacts{1,i}.FilmReview.ImpactType;
        class{i} = confirmedImpacts{1,i}.FilmReview.ImpactClass;
        la(i) = confirmedImpacts{1,i}.PeakValues.LinAcc;
        rv(i) = confirmedImpacts{1,i}.PeakValues.RotVel;
        ra(i) = confirmedImpacts{1,i}.PeakValues.RotAcc;
    end
    
    dates = unique(date);
    numDates = length(dates);
    mps = unique(mp);
    numMps = length(mps);
    types = unique(type);
    numTypes = length(types);
    classes = unique(class);
    numClasses = length(classes);
    
    mean_la = mean(la);
    std_la = std(la);
    min_la = min(la);
    perc25_la = prctile(la,25);
    median_la = median(la);
    perc75_la = prctile(la,75);
    perc95_la = prctile(la,95);
    max_la = max(la);
    
    mean_rv = mean(rv);
    std_rv = std(rv);
    min_rv = min(rv);
    perc25_rv = prctile(rv,25);
    median_rv = median(rv);
    perc75_rv = prctile(rv,75);
    perc95_rv = prctile(rv,95);
    max_rv = max(rv);
    
    mean_ra = mean(ra);
    std_ra = std(ra);
    min_ra = min(ra);
    perc25_ra = prctile(ra,25);
    median_ra = median(ra);
    perc75_ra = prctile(ra,75);
    perc95_ra = prctile(ra,95);
    max_ra = max(ra);
    
    row_labels = {'';'linear acceleration (g)';'rotational velocity (rad/s)';'rotational acceleration (rad/s^2)'};
    column_labels = {'mean','standard dev','min','25%','50%','75%','95%','max'};
    dataOut0 = [mean_la std_la min_la perc25_la median_la perc75_la perc95_la max_la;
        mean_rv std_rv min_rv perc25_rv median_rv perc75_rv perc95_rv max_rv;
        mean_ra std_ra min_ra perc25_ra median_ra perc75_ra perc95_ra max_ra];
    dataOut1 = horzcat(row_labels,vertcat(column_labels,num2cell(dataOut0)));
    
    row_labels2 = {'# impacts';'# impact days';'# MPs'};
    dataOut00 = [num; numDates; numMps];
    dataOut01 = horzcat(row_labels2,num2cell(dataOut00),{'','','','','','','';'','','','','','','';'','','','','','',''});
    dataOut02 = {'','','','','','','','',''};
    
    dataOut = vertcat(dataOut01,dataOut02,dataOut1);
    
    xlswrite(fullfile(masterLoc,filenameOut),dataOut,'All')
    
    date0 = date;
    la0 = la; rv0 = rv; ra0 = ra;
    clear('la','rv','ra','date','dataOut')
    for i = 1:numMps
        currMp = mps{i};
        ind = find(strcmp(mp,currMp));
        num = length(ind);
        la = la0(ind);
        rv = rv0(ind);
        ra = ra0(ind);
        date = date0(ind);
        dates = unique(date);
        numDates = length(dates);
        
        mean_la = mean(la);
        std_la = std(la);
        min_la = min(la);
        perc25_la = prctile(la,25);
        median_la = median(la);
        perc75_la = prctile(la,75);
        perc95_la = prctile(la,95);
        max_la = max(la);

        mean_rv = mean(rv);
        std_rv = std(rv);
        min_rv = min(rv);
        perc25_rv = prctile(rv,25);
        median_rv = median(rv);
        perc75_rv = prctile(rv,75);
        perc95_rv = prctile(rv,95);
        max_rv = max(rv);

        mean_ra = mean(ra);
        std_ra = std(ra);
        min_ra = min(ra);
        perc25_ra = prctile(ra,25);
        median_ra = median(ra);
        perc75_ra = prctile(ra,75);
        perc95_ra = prctile(ra,95);
        max_ra = max(ra);
        clear('la','rv','ra','date')
        
        dataOut0 = [mean_la std_la min_la perc25_la median_la perc75_la perc95_la max_la;
        mean_rv std_rv min_rv perc25_rv median_rv perc75_rv perc95_rv max_rv;
        mean_ra std_ra min_ra perc25_ra median_ra perc75_ra perc95_ra max_ra];
        dataOut1 = horzcat(row_labels,vertcat(column_labels,num2cell(dataOut0)));
    
        row_labels2 = {'# impacts';'# impact days'};
        dataOut00 = horzcat(row_labels2,num2cell([num; numDates]),{'','','','','','','';'','','','','','',''});
        dataOut01 = {'','','','','','','','',''};
    
        dataOut = vertcat(dataOut00,dataOut01,dataOut1);
        xlswrite(fullfile(masterLoc,filenameOut),dataOut,currMp)
        clear('dataOut')
    end
    
else end
end