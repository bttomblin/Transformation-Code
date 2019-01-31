clc; clear;

film_dir = uigetdir('\\medctr\dfs\cib$\shared\02_projects\mouthpiece_data_collection\soccer');
film_files = dir(film_dir);

MONTHS = {'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'};

for i = 3:length(film_files) % start at 3
    date_parts = strsplit(film_files(i).name,'-');
    year = date_parts{1};
    
    if(isnan(str2double(year))==0) % only go through folder with valid dates (sometimes extra folders are in the film review directory)
        month = date_parts{2};
        month_str = MONTHS{str2double(month)};
        day = date_parts{3};
        date = strcat(month_str,'_',day,'_',year(3:end));
        date_dir = fullfile(film_dir, film_files(i).name);
        date_files = dir(fullfile(date_dir,'*Review*.xlsx'));
        
        if (isempty(date_files)) % check if film review file exists
            msg = cell(4,1);
            msg{1,1} = sprintf('ERROR: No film review file exists for this date.');
            msg{2,1} = sprintf('%s',date);
            errordlg(msg);
        else
            file_film_review = date_files(1).name;   

            [num,txt] = xlsread(fullfile(date_dir, file_film_review));

            idx_active = 1;
            active_MPs = {};
            for j = 1:length(txt(1,:)) % get list of active MPs on this date
                if(contains(txt{1,j},'MP') && ~contains(txt{1,j},'sec'))
                    active_MPs{idx_active} = txt{1,j};
                    idx_active = idx_active + 1;
                end
            end

            n_active = length(active_MPs);
            n_rows = size(txt,1);

            right_col_num = 64+9+6*(n_active-1);
            right_col_char = char(64+9+6*(n_active-1));

            if (right_col_num > 90) % call the correct column letter in excel
                add_cols = mod(right_col_num,90);
                right_col_char = strcat('A',char(64+add_cols));
            end
            if (right_col_num > 116)
                add_cols = mod(right_col_num,116);
                right_col_char = strcat('B',char(64+add_cols));
            end
            if (right_col_num > 142)
                add_cols = mod(right_col_num,142);
                right_col_char = strcat('C',char(64+add_cols));
            end

            table_film_review = readtable(fullfile(date_dir, file_film_review),'Range',strcat(char(69),'2',':',right_col_char,num2str(n_rows))); % read in film review data for each MP

            for k=1:n_active      % loop through active MPs
                film_review_mp = table_film_review(:,1+6*(k-1):5+6*(k-1));
                varNames = film_review_mp.Properties.VariableNames;

                for j=1:length(varNames) 
                    if contains(varNames{j},'_') % get rid of underscores in table headers
                        var = varNames{j};
                        idx_cutoff = find(var == '_');
                        film_review_mp.Properties.VariableNames{var} = var(1:idx_cutoff-1);
                    end
                    if (strcmp(film_review_mp.Properties.VariableNames{j},'ImpactNumber')) % some film review calls it "impact number" instead of "event number"
                        film_review_mp.Properties.VariableNames{'ImpactNumber'} = 'EventNumber';
                    end
                end

                if(~any(contains(film_review_mp.Properties.VariableNames,'EventNumber'))) % check EventNumber field exists
                    msg = cell(4,1);
                    msg{1,1} = sprintf('ERROR: No EventNumber field in film review structure.');
                    msg{2,1} = sprintf('%s, %s',date,active_MPs{k});
                    errordlg(msg);
                else

                    if(any(strcmp(film_review_mp.Description,"")))
                        remove_idx1 = strcmp(film_review_mp.Description,"");
                        remove_idx2 = strcmp(film_review_mp.Description,'Description');
                        keep_idx = ~(remove_idx1 + remove_idx2);
                        film_review_mp = film_review_mp(keep_idx,:);
                    end

                    if(iscell(film_review_mp.VideoTime))
                        film_review_mp.VideoTime = str2double(film_review_mp.VideoTime);          
                    end
                    if(iscell(film_review_mp.ActualTime))
                        film_review_mp.ActualTime = str2double(film_review_mp.ActualTime);
                    end
                    if(iscell(film_review_mp.EventNumber))
                        film_review_mp.EventNumber = str2double(film_review_mp.EventNumber);
                    end

                    film_review_mp = film_review_mp(~isnan(film_review_mp.ActualTime),:);
                    
                    if(any(isnan(film_review_mp.EventNumber))) % make PFNs have an EventNumber of 0
                        film_review_mp.EventNumber(isnan(film_review_mp.EventNumber)) = 0;
                    end
                    
                    if(any(isnan(film_review_mp.VideoTime)) && all(film_review_mp.EventNumber == 0))
                        msg = cell(4,1);
                        msg{1,1} = sprintf('ERROR: Film review file not complete.');
                        msg{2,1} = sprintf('%s, %s',date,active_MPs{k});
                        errordlg(msg);                                       
                    elseif( any(film_review_mp.EventNumber(strcmp(film_review_mp.Description,'Before')) == 0) || any(film_review_mp.EventNumber(strcmp(film_review_mp.Description,'After')) == 0) )
                        msg = cell(4,1);
                        msg{1,1} = sprintf('ERROR: Film review description of Before or After has no associated MP impact.');
                        msg{2,1} = sprintf('%s, %s',date,active_MPs{k});
                        errordlg(msg);                          
                    else
                        impact_table = table(film_review_mp.EventNumber,film_review_mp.Description,string(datestr(film_review_mp.VideoTime,'HH:MM:SS')),string(datestr(film_review_mp.ActualTime,'HH:MM:SS')),string(film_review_mp.Confirmed),'VariableNames',{'Impact_Number','Impact_Type','Film_Time','Impact_Time','Impact_Class'});
                        if(any(ismissing(impact_table.Impact_Class)))
                            impact_table.Impact_Class(ismissing(impact_table.Impact_Class)) = "";
                        end
                        FILM_REVIEW.(date).(active_MPs{k}) = impact_table;
                    end
                end
            end
        end
    end
end

currDate = datestr(now);
save(fullfile(film_dir, strcat('FILM_REVIEW_',currDate(1:end-9),'.mat')), 'FILM_REVIEW');