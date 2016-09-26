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
% get proper information in loc_calc file.

% folder with .wav files used to make LTSA
% path_in='I:\score\2015\data\sg158-HF-125kHz\';
% folder with .flac files 
path_in = 'I:\score\2015\data\sg158\';

% files=dir([path_in '*.wav']);
files=dir([path_in '*.flac']);

PAM=[];
% make matrix with start and end times for all PAM files
for f=1:length(files);
    % get timing information from file name
    % wispr files are 80 secs long (check this by comparing time in file
    % name (start time) to date file was written)
    start_d=datenum([files(f).name(1:13)],'yymmdd-HHMMSS');
    end_d=start_d+datenum(0,0,0,0,1,20); % 80 secs later..may not need this
PAM_i=[start_d end_d];
    PAM=[PAM; PAM_i];
end

locCalc(:,9)=zeros(1,length(locCalc(:,9)));
for f=1:length(locCalc(:,2))
    pair=[];
    YN=0;
    for g=1:length(PAM(:,1))
        if locCalc(f,2)>=PAM(g,1) & locCalc(f,2)<=PAM(g,2)
            pair=[pair; f g];
            YN=1;
        end           
    end
    %disp(pair);
   if YN==1;
       locCalc(f,9)=YN;
   end
   
end


col_name='Dive,time,latitude,longitude,depth,temperature,salinity,soundvelocity,PAM';

save([gldr '_' lctn '_' dplymnt '_locCalc.mat'],'locCalc');
dlmwrite([gldr '_' lctn '_' dplymnt '_locCalc.csv'],col_name,'delimiter','');
dlmwrite([gldr '_' lctn '_' dplymnt '_locCalc.csv'],locCalc,'delimiter',...
    ',','precision','%.6f','-append');

