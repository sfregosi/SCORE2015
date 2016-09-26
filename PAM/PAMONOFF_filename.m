% specifies when the pam system was on and off. 
% may need to adjust time zone manually afterwards. 

clear all
clc
gldr='sg158';
lctn='SCORE';
dplymnt='Dec15';

cd('V:\sg158_20151221_SCORE\profiles\');

% path_in='X:\Gliders\2012_06_12_Washington_sg178_sg179\sg179\usba\';
path_in='H:\score\2016\sg158_score_Dec15_wav\';
%folders=dir(path_in);


PAM=[];
n=1;

for i=3:length(folders)
    dive=str2double(folders(i,1).name(5:7))
%     files=dir([path_in folders(i,1).name '\' '*.flac']);
     % files=dir([path_in folders(i,1).name '\' '*.wav']);
    try
        start_d=datenum([files(1).name(7:21)],'yyyymmdd-HHMMSS');
        end_d_s=datenum([files(end).name(7:21)],'yyyymmdd-HHMMSS');
        end_d=end_d_s+datenum(0,0,0,0,0,60);
        dur_d=(end_d-start_d)*86400/60/60;
        PAM_i=[dive start_d end_d dur_d];
        PAM=[PAM; PAM_i];
        n=n+1;
    catch
        disp(['Dive ' num2str(dive) ': empty folder']);
    end
end

save([gldr lctn dplymnt '-PAMON'],'PAM');