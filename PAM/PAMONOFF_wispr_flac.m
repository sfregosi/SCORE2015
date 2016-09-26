% PAM ON/OFF information for WISPR board Gliders

clear all
clc
gldr='sg158';
lctn='SCORE';
dplymnt='Dec15';

cd(['i:\score\2015\profiles\' gldr '_' lctn '_' dplymnt '\']);
load([gldr '_' lctn '_' dplymnt '_gpsSurface.mat']);
load([gldr '_' lctn '_' dplymnt '_locCalc.mat']);
% will have had to run this code without PAMON file, then re-run it with to
% get proper information in locCalc file.

% folder with .wav files used to make LTSA
% path_in='I:\score\2015\data\sg158-HF-125kHz\';
% folder with .flac files
path_in = ['I:\score\2015\data\' gldr '\'];

% files=dir([path_in '*.wav']);
files=dir([path_in '*.flac']);
% files.date and files.datenum is the write time
% filename has start of file time
% the difference is about

PAMfiles=[];
% make matrix with start and end times for all PAM files
% have to pull it from filename

for f = 1:length(files);
% for f=40:length(files); % start at 40 for glider because of selftest
                            % files from dec 7
    % get timing information from file name
    % wispr files are ~80 secs long
    startT=datenum(files(f).name(7:19),'yymmdd_HHMMSS');
    endT=startT+datenum(0,0,0,0,1,20); % 80 secs later..may not need this
    PAM_i=[startT endT];
    PAMfiles=[PAMfiles; PAM_i];
end

%want to get course start and end times for each dive
%to do that, calculate the difference between start times and mark anywhere
%that it is greater than 85 seconds (0.000925925925925926)
for g = 2:length(PAMfiles)
    PAMfiles(g-1,3) = (PAMfiles(g,1)-PAMfiles(g-1,1))*86400;
end

%************ SKIP THIS WHEN REPEATING/FOR QUEPHONES ****************
[row,col] = find(PAMfiles(:,3) > 85);
% this gives me the row numbers that are the LAST file of a dive.
% row +1 is the START of the next dive

% complication - testing in early december. Can remove these with a less
% than indexing?
% No - I can see the actual survey starts on row 40, so just going to
% loop through files starting at 40:length above.

% ok that gives me 70 "gaps"
% had 67 dives....
% lets look at the "gaps"
row(:,2) = (PAMfiles(row(:,1),3))/60; % in mins
% most are 20_ mins, some are only 1.7 mins.
% going to take it by hand now
% remember - row location is END of dive. So print out those as datestrs
endR = datestr(PAMfiles(row(:,1),1));
endD = datestr(gpsSurf(:,5));
startD = datestr(gpsSurf(:,2));
startR = datestr(PAMfiles(row(:,1)+1,2));

% ok after rabbit hole of doing this by hand. Few instances when there are
% gaps that are only about 2 mins, it is just the buffer overrunning, but
% otherwise is fine - ignore these instances (4 total)
% Dives 3 and 4 are weird - recording started late and ended late (After
% glider had surfaced) Gap here is only 4 or 5 mins, but still want this
% break, so will use 3 mins as cut off.

% ** Q001 - with 2 min cut off, get 14 issues, one on dive 4, where buffer
% must have had same issue. So also ran with 3 mins, which gave 13, which
% is correct for 14 dives. 

% *********** PICK UP HERE ************
[row,col] = find(PAMfiles(:,3) > 3*60);
% ok, that gives me 66, which is correct - for sg158
% gives 13 for q001
% gives 13 for q002

% so create matrix with DIVE PAMStart PAMEnd PAMDur
PAM = [1:1:14]'; % fill in dive nums
PAM(1,2) = PAMfiles(1,1); % set first file as first start for dive 1.
PAM(14,3) = PAMfiles(end,2); % set end of last file as end for dive 67
% fill in the rest
PAM(2:end,2) = PAMfiles(row(:,1)+1,1);
PAM(1:end-1,3) = PAMfiles(row(:,1),2);
PAM(:,4) = (PAM(:,3)-PAM(:,2))*24; % in hours

% save it!!!
save([gldr '_' lctn '_' dplymnt '-PAMON'],'PAM');

col_name='diveNum,startRec,endRec,dur';
dateFmt = 'mm/dd/yyyy HH:MM:SS';

fid = fopen([gldr '_' lctn '_' dplymnt '-PAMON.csv'], 'w');
fprintf(fid, '%s\n', col_name);
for h = 1 : length(PAM)
    fprintf(fid, '%d,%s,%s,%.4f\n', ...
        PAM(h,1), ...
        datestr(PAM(h,2), dateFmt), ...
        datestr(PAM(h,3),   dateFmt), ...
        PAM(h,4));
end
fclose(fid);

% END HERE ***********

% load([gldr '_' lctn '_' dplymnt '-PAMON'])
% dlmwrite([gldr '_' lctn '_' dplymnt '-PAMON.csv'],col_name,'delimiter','');
% dlmwrite([gldr '_' lctn '_' dplymnt '-PAMON.csv'],PAM,'delimiter',...
%     ',','precision','%.6f','-append');

%% INPUT THE PAM/ON 0/1 values into the locCalc table.
cd(['i:\score\2015\profiles\' gldr '_' lctn '_' dplymnt '\']);
load([gldr '_' lctn '_' dplymnt '-PAMON.mat']);
load([gldr '_' lctn '_' dplymnt '_gpsSurface.mat']);
load([gldr '_' lctn '_' dplymnt '_locCalc.mat']);

locCalc(:,9)=zeros(1,length(locCalc(:,9)));

for f=1:length(locCalc(:,1))
    pair=[];
    YN=0;
    for g=1:length(PAM(:,1))
        if locCalc(f,2)>=PAM(g,2) & locCalc(f,2)<=PAM(g,3)
            pair=[pair; f g];
            YN=1;
        end
    end
    %disp(pair);
    if YN==1;
        locCalc(f,9)=YN;
    end
end

% check by plotting time and depth?
plot(locCalc(:,2),-locCalc(:,5),'k');
hold on
plot(locCalc(:,2),-locCalc(:,1),'r');
colormat = locCalc(:,9);
scatter(locCalc(:,2),-locCalc(:,5),4,colormat,'filled');
title([gldr ' profile']);
hold off

col_name='Dive,time,latitude,longitude,depth,temperature,salinity,soundvelocity,PAM';

save([gldr '_' lctn '_' dplymnt '_locCalc.mat'],'locCalc');
dlmwrite([gldr '_' lctn '_' dplymnt '_locCalc.csv'],col_name,'delimiter','');
dlmwrite([gldr '_' lctn '_' dplymnt '_locCalc.csv'],locCalc,'delimiter',...
    ',','precision','%.6f','-append');

