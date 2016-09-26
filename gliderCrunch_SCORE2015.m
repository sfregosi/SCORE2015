% Process annotation data (what species were seen when) and glider operation
% data (lat/lons of dives, times when PAM system was on) to produce an output
% file per species that has (1) geo- and time-information about each dive, (2)
% how many seconds that species was present, and (3) the fraction of the PAM-on
% times that the species was present. Also produce, for each species, an
% 'encounter' file with information about each encounter.
clear all
clc
gldr='q001';
lctn='SCORE';
dplymnt='Dec15';
% type=2; % 1 for glider, 2 for float - this may not matter if you run queProfiles

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Configuration. Edit this part as needed.
% speciesList says what species to look for in the annotation files. The abbrev
% speciesList = struct( ...
%        'abbrev',{'Oo'}, ...
%        'name',	{'killerwhale'} ...
%       );

speciesList = struct( ...
    'abbrev',	{'delphinid', 'Mn', 'Bp', 'Bm',...
    'Bm-D','Gg','Oo','UBW'}, ...
    'name',	{'delphinid', 'Mn', 'Bp', 'Bm',...
    'Bm-D','Gg','Oo','UBW'} ...
    );

dir='i:\score\2015\annotations\';
profdir=['i:\score\2015\profiles\' gldr '_' lctn '_' dplymnt '\']; %sf dir....gldr '_' lctn '_' dplymnt '\'

% annFile has information about human annotations of the data.
% It has columns of [Selection View Channel Time(s) End Low High BeginDate Time EndDate EndClockTime species]
% It has a header line, so start reading at the second line.
% Annotations can span multiple dives.

% annFile  = [dir 'HRC2014_allbaleen2_both_1_10khz.xlsx'];
annFile  = [dir gldr '_' lctn '_' dplymnt '_all.xls'];
annSheet = 'Sheet1';
encMergeTimeSec = 30*60;        % that's 30 minutes

% diveFile has information about the glider track.
% It has columns of [dive starttime startlatitude startlongitude endtime
%     endlatitude endlongitude duration(hours) midlatitude midlongitude
%     labelbydive]
% It has a header line, so start reading at the second line.
diveFile = [profdir gldr '_' lctn '_' dplymnt '_gpsSurface.csv'];

% diveCalcFile has information about the glider's position every 10 seconds.
% Data in between surfacings is dead-reckoned.
diveCalcFile = [profdir gldr '_' lctn '_' dplymnt '_locCalc.csv'];

% pamFile has information about when the PAM system is on. The columns
% [divenumber starttime endtime duration], with starttime and endtime in
% datenum format and duration in hours (!).
pamFile = [profdir gldr '_' lctn '_' dplymnt '-PAMON.mat'];

% This is used to create the output files. It gets species name and .csv
% appended.
outFileRootDive = [dir 'results\' gldr '_' lctn '_' dplymnt '_byDive'];
outFileRootCall = [dir 'results\' gldr '_' lctn '_' dplymnt '_byCall'];
outFileRootAnn  = [dir 'results\' gldr '_' lctn '_' dplymnt '_byAnn'];
outFileRootEnc  = [dir 'results\' gldr '_' lctn '_' dplymnt '_byEnc'];

% dateFmt says how dates will be printed out in the .csv files.
% need this specific format for arc to read it. 
% trying different one...
% dateFmt = 'mm/dd/yyyy HH:MM';
dateFmt = 'yyyy-mm-dd HH:MM:SS.FFF';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% end of configuration %%%%%%%%%%%%%%%%%%%%%%%%%

%% Read data files. Read them in raw form first.

%fprintf(1, 'Reading files... ');
[~,~,annRaw] = xlsread(annFile, annSheet);
diveRaw = csvread(diveFile, 1, 0);	% '1' means start reading at second line
calcRaw = csvread(diveCalcFile, 1, 0);

 load(pamFile);
%fprintf(1, 'Done.\n');

%% Pre-process raw data, mainly by converting into structs with meaningful
% names.
fprintf(1, 'Converting input data to convenient structures... ');

%odonts/sf modified sheets.
ann = struct(...				% ann is an array of structs
    'encounter',	annRaw(2:end, 1), ...	% skip first (header) line
    'startDate',	annRaw(2:end, 2), ...
    'endDate',		annRaw(2:end, 3), ...
    'species',      annRaw(2:end, 4) ...
    );
nAnn = length(ann);

for ai=1:nAnn
    ann(ai).t0=datenum(ann(ai).startDate);
    ann(ai).t1=datenum(ann(ai).endDate);
end

% if type==1; % for glider
    dive = struct(...		     % dive is a struct; each field is an array
        'dive',         diveRaw(:, 1), ...
        'startTime',	diveRaw(:, 2), ...
        'startLat',		diveRaw(:, 3), ...
        'startLon',		diveRaw(:, 4), ...
        'endTime',		diveRaw(:, 5), ...
        'endLat',		diveRaw(:, 6), ...
        'endLon',		diveRaw(:, 7), ...
        'duration',		diveRaw(:, 8), ... % this is in hours
        'midTime',      diveRaw(:, 9), ...
        'midLatitude',	diveRaw(:, 10), ...
        'midLongitude',	diveRaw(:, 11), ...
        ... %     'depthavgcurrentnorth', diveRaw(:, 12), ...
        ... %     'depthavgcurrenteast', diveRaw(:, 13), ...
        'labelByDive',	diveRaw(:, 12) ...
        );
    
    nDive = length(dive.dive);
    
    calc = struct(...		     % calc is a struct; each field is an array
        'dive',         calcRaw(:, 1), ...
        'time',         calcRaw(:, 2), ...
        'latitude',		calcRaw(:, 3), ...
        'longitude',	calcRaw(:, 4), ...
        'depth',		calcRaw(:, 5), ...
        'temperature',  calcRaw(:, 6), ...
        'salinity',     calcRaw(:, 7), ...
        'soundvelocity',calcRaw(:, 8), ...
        'PAM',          calcRaw(:, 9) ...
        );
     
% else % FOR FLOATS
%     dive = struct(...		     % dive is a struct; each field is an array
%         'dive',         diveRaw(:, 1), ...
%         'startTime',	diveRaw(:, 2), ...
%         'endTime',      diveRaw(:, 3), ...
%         'latitude',		diveRaw(:, 4), ...
%         'longitude',	diveRaw(:, 5), ...
%         'midLatitude',  diveRaw(:, 4), ...
%         'midLongitude', diveRaw(:, 5) ...
%         );
%     
%     calc = struct(...		     % calc is a struct; each field is an array
%         'dive',         calcRaw(:, 1), ...
%         'time',         calcRaw(:, 2), ...
%         'latitude',		calcRaw(:, 3), ...
%         'longitude',	calcRaw(:, 4), ...
%         'depth',		calcRaw(:, 5), ...
%         'PAM',          calcRaw(:, 6) ...
%         );
% end

  pam = struct(...		     % pam is a struct; each field is an array
        'dive',         PAM(:, 1), ...
        'onTime',		PAM(:, 2), ...
        'offTime',      PAM(:, 3), ...
        'durSec',		PAM(:, 4) * 60*60 ...	% PAM(:,4) is in HOURS!!
        );
%     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% ********************************************************
% If nDive doesnt match up with total num dives (ie SG204 MIRC 2015)
% add in lines to diveRaw for missing dives with zeroes now and rerun the
% dive struct command...otherwise gliderCrunchByDive.m isn't big enough!
% ********************************************************

% DONT NEED THIS FOR ODONTS?
% just use startTime as t0 and endTime as t1
fprintf(1, 'Done.\n');

%% Process by dive. Do each species in turn.
% %DONT CARE ABOUT THIS FOR SCORE/AFFOGATO WORK

% printf('Processing by species....')
% for si = 1 : length(speciesList)	% loop through all desired species
%     % Do the work.
%     r = gliderCrunchByDive(speciesList(si), ann, dive, calc, pam);
%     
%     % Save results to a .csv file. Actually two .csv files, the second one
%     % omitting dives without any encounter of the given species.
%     outF   = [outFileRootDive '_' speciesList(si).name '.csv'];
%     outFnz = [outFileRootDive '_' speciesList(si).name '_nozero.csv'];
%     printf('Creating %s ...', pathFile(outF));
%     [~,~,~] = mkdir(pathDir(outF));	% the return args prevent an error msg
%     fd   = fopen(outF,   'w');
%     fdnz = fopen(outFnz, 'w');
%     fprintf(fd,   'DiveNum,DiveStartTime,DiveEndTime,DiveMidTime,DiveMidLat,DiveMidLon,DiveDur,PamOnSec,SpSecPresent,SpPctPresent\n');
%     fprintf(fdnz, 'DiveNum,DiveStartTime,DiveEndTime,DiveMidTime,DiveMidLat,DiveMidLon,DiveDur,PamOnSec,SpSecPresent,SpPctPresent\n');
%     for ri = 1 : length(r)
%         str = sprintf('%d,%s,%s,%s,%.5f,%.5f,%.5f,%.3f,%.3f,%.2f', ...
%             r(ri).diveNum, datestr(r(ri).startTime, dateFmt), ...
%             datestr(r(ri).endTime, dateFmt), datestr(r(ri).midTime, dateFmt), ...
%             r(ri).midLat, r(ri).midLon, r(ri).diveDur, r(ri).pamOnSec, ...
%             r(ri).spPresentSec,	r(ri).fracPresent * 100);
%         fprintf(fd, '%s\n', str);
%         if (r(ri).spPresentSec ~= 0), fprintf(fdnz, '%s\n', str); end
%     end
%     fclose(fd);
%     fclose(fdnz);
% end
% 
% fprintf(1, 'Done.\n');

%% Process by call
%
% this is most useful for baleen whales where every call is marked, but it
% also is basically a different output for the annotations. It outputs the
% lat/lon/depth/dive for the START of ann annotation, regardless of 30 min
% binning.
fprintf('Processing by call....\n')

for si = 1 : length(speciesList)
    
    c = gliderCrunchByCall(speciesList(si), ann, dive, calc);
    % Save results to a .csv file.
    outF   = [outFileRootCall '_' speciesList(si).name '.csv'];
    printf('Creating %s ...', pathFile(outF));
    [~,~,~] = mkdir(pathDir(outF));	% the return args prevent an error msg
    fd   = fopen(outF, 'w');
    fprintf(fd, 'num,startTime,endTime,lat,lon,depth,dive\n');
    for ci = 1 : length(c)       
        str = sprintf('%d,%s,%s,%.5f,%.5f,%.3f,%d', ...
            ci, ...
            datestr(c(ci).startTime,dateFmt), ...
            datestr(c(ci).endTime,dateFmt), ...
            c(ci).lat, c(ci).lon, c(ci).depth, c(ci).dive);
        fprintf(fd, '%s\n', str);
    end
    fclose(fd);
end

fprintf(1, 'Done.\n');
%% Process by annotation and by encounter. Do each species in turn.
% This loop is done twice, the first time for annotations and the second time
% for encoutners (merged annotations).
for qq = 1:2		% 1 is for annotations, 2 is for encounters
    if (qq == 1)
        x = ann;
        headerStr = 'annNum,annStartTime,annEndTime,annMidTime,annDurSec,diveNum,diveMidLat,diveMidLon,annMinDepth,annMaxDepth';
        outF = outFileRootAnn;	% gets appended to below
    else
        x = gliderMergeAnnIntoEnc(ann, encMergeTimeSec);
        headerStr = 'encNum,encStartTime,encEndTime,encMidTime,encDurSec,diveNum,diveMidLat,diveMidLon,encMinDepth,encMaxDepth';
        outF = outFileRootEnc;	% gets appended to below
    end
    for si = 1 : length(speciesList)
        % Do the work.
        e = gliderCrunchByEncounter(speciesList(si), x, dive, calc, pam);
        
        % Save results to a .csv file.
        outF1 = [outF '_' speciesList(si).name '.csv'];
        printf('Creating %s ...', pathFile(outF1));
        [~,~,~] = mkdir(pathDir(outF1));	% the return args prevent an error msg
        fd = fopen(outF1, 'w');
        fprintf(fd, '%s\n', headerStr);
        for ei = 1 : length(e)
            fprintf(fd, '%d,%s,%s,%s,%.2f,%d,%.5f,%.5f,%.1f,%.1f\n', ...
                ei, ...
                datestr(e(ei).annStartTime, dateFmt), ...
                datestr(e(ei).annEndTime,   dateFmt), ...
                datestr(e(ei).annMidTime,   dateFmt), ...
... %                 e(ei).annDurSec/60/60, ...
e(ei).annDurSec, ...
                e(ei).diveNum, ...
                e(ei).diveMidLat, e(ei).diveMidLon, ...
                e(ei).annMinDepth, e(ei).annMaxDepth);
        end
        fclose(fd);
    end
end

%% Warn user about annotations that didn't match.
sl1 = speciesList;		% make a copy because we might add to it
preface = ['Species names in the annotation file that weren''t processed here:' 10];
for ai = 1 : nAnn
    % Check to see whether the species in this annotation is known. Do this by
    % walking through all known species looking for a hit.
    hit = false;
    for si = 1 : length(sl1)
        hit = hit || gliderSpeciesMatch(ann(ai).species, sl1(si).abbrev);
    end
    if (~hit)
        % Didn't find this annotation's species in the known list. Report it.
        fprintf(1, '%s', preface);
        preface = '';
        printf('    %-10s (first seen on line %d)', ann(ai).species, ...
            ai+1);				% +1 accounts for header line in file
        
        % Add newly-found species to sl1 so we don't report it multiple times.
        sl1(end+1).abbrev = ann(ai).species;		%#ok<SAGROW>
        sl1(end).name = ann(ai).species;
    end
end
