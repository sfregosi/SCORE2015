% SCORE BW spatial analyses
%
% This my running script for a variety of analysis goals, as I finalize
% them, I will pull them out into separate scripts, but I want to use this
% as my working space
%
%
% I started this on baleen but can't remote login sooo I'm starting over.
%% Working directory/details
instr = 'sg158_SCORE_Dec15';

path = ['E:\score\2015\'];
cd([path 'matlab\']);

annPath = [path 'annotations\results\'];
profPath = [path 'profiles\' instr '\'];

%% Import the csvs and make them into just a matlab matrix
filename = [annPath instr '_byEnc_UBW.csv'];
delimiter = ',';
formatSpec = '%f%s%s%s%f%f%f%f%f%f%[^\n\r]';

fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines', 1, 'ReturnOnError', false);
fclose(fileID);

dataArray{2} = datenum(dataArray{2}, 'yyyy-mm-dd HH:MM:SS.fff');
dataArray{3} = datenum(dataArray{3}, 'yyyy-mm-dd HH:MM:SS.fff');
dataArray{4} = datenum(dataArray{4}, 'yyyy-mm-dd HH:MM:SS.fff');

data = dataset(dataArray{1:end-1}, 'VarNames', {'encNum','encStartTime','encEndTime','encMidTime','encDurHr','diveNum','diveMidLat','diveMidLon','encMinDepth','encMaxDepth'});
clearvars filename delimiter formatSpec fileID dataArray ans;

%% Plot simple histogram of detections vs depth

hist(data.encMinDepth,100)
hist(data.encMaxDepth,100)

