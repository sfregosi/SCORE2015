% gliderCrunch_summarize

% takes results output from gliderCrunch and summarizes number of species,
% duration of encounters, and other summary statistics.

clear all
clc
gldr='q002';
lctn='SCORE';
dplymnt='Dec15';
type=1; % 1 for glider, 2 for float
prefix=[gldr '_' lctn '_' dplymnt '_'];
% folder location glider crunch .csv outputs
% path_in='V:\sg158_q001_q002_20151222_SCORE\annotations\results\';
path_in=['C:\Users\sfreg_000\SkyDrive\gliders_local\AFFOGATO\2015_12_SCORE\'...
    'sg158_q001_q002_20151222_SCORE\annotations\results\'];
cd(path_in)

%% generate list of .csv's relevant to this instrument

files=dir([path_in prefix '*.csv']);
suffix={'byAnn' 'byCall' 'byDive' 'byEnc'};
% make lists by the different suffices
for f=1:length(suffix)
    fls.(suffix{f})=dir([path_in prefix suffix{f} '_*.csv']);
end

% summarize the following:
% Number of species/call types detected by instrument
numSp=length(fls.byAnn);
disp(['Number of species: ' num2str(numSp)]);

% For each species: num of encounters, number of calls, num of dives with
% detections, total dur
sumOut={};
colHeaders={'sp' 'numEnc' 'numDives' 'durHr'};
for f=1:numSp;
    %     for g=1:length(suffices)
    raw=crunchImport(fls.byEnc(f,1).name);
    sumOut{f,1}=fls.byEnc(f,1).name((length(prefix)+length(suffix{1,4})+2):end-4);
    sumOut{f,2}=length(raw.encNum);
    sumOut{f,3}=length(unique(raw.diveNum));
    sumOut{f,4}=sum(raw.encDurHr);
    % num of calls later??
end


%% export it
fid=fopen([prefix 'summary.csv'],'w');
fprintf(fid,'species,numEnc,numDives,durHr\n');
for i=1:length(sumOut)
    str = sprintf('%s,%d,%d,%.3f',...
        sumOut{i,1},sumOut{i,2},sumOut{i,3},sumOut{i,4});
    fprintf(fid, '%s\n', str);
end
fclose(fid);