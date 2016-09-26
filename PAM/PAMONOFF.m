% specifies when the pam system was on and off. 
% may need to adjust time zone manually afterwards. 
% this works for when the .flac files are in individual folders by dive

clear all
clc

path_in='N:\projects\2014_HDR_NorthPacific_S1045\HRC-2014\raw\';
folders=dir(path_in);
deployment='HRC-PAMON';

PAM=[];
n=1;

for i=3:length(folders)
    dive=str2double(folders(i,1).name(5:7))
    files=dir([path_in folders(i,1).name '\' '*.flac']);
    try
        start_d=files(1).datenum;
        end_d=files(end).datenum;
        dur_d=(end_d-start_d)*86400/60/60;
        PAM_i=[dive start_d end_d dur_d];
        PAM=[PAM; PAM_i];
        n=n+1;
    catch
        disp(['Dive ' num2str(dive) ': empty folder']);
    end
end

save(deployment,'PAM');