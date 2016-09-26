% Working with SCORE data - moving forward on analysis

% Quick look at detections vs depth

% most up to date data is in
path = 'Y:\Glider\sg158_q001_q002_20151222_SCORE\';

encFile = [path 'annotations\results\sg158_SCORE_Dec15_byEnc_UBW.csv'];

%% Import data = create useable matlab matrix
% columns are 1enc 2start 3end 4mid 5dur 6diveNum 7midLat 8midLon 9minDep 10maxDep
delimiter = ',';
startRow = 2;

formatSpec = '%f%s%s%s%f%f%f%f%f%f%[^\n\r]';

fileID = fopen(encFile,'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);
fclose(fileID);
dataArray{2} = datenum(dataArray{2}, 'yyyy-mm-dd HH:MM:SS.FFF');
dataArray{3} = datenum(dataArray{3}, 'yyyy-mm-dd HH:MM:SS.FFF');
dataArray{4} = datenum(dataArray{4}, 'yyyy-mm-dd HH:MM:SS.fff');

sg158UBW = [dataArray{1:end-1}];

clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% Plot Min depth histogram
hist(sg158UBW(:,9))
hist(sg158UBW(:,10))

% normalize for recording time at that depth, and duration of encounters

