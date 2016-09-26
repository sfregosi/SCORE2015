% Working with SPAWAR SCORE baleen data from c3d program

% see notes on file formats, etc

% goals are to take their data files and make into .mat, adjust timing so I
% can work on them in here, and look at all data at once

% for now ignore beaked whales (will get those from NUWC)
clear all

addpath('i:\score\2015\matlab\');
path='i:\score\2015\c3d\';
cd(path);
% daterange = '2015_1221-27';
% daterange = '2015_1227-31';
daterange = '2016_0103-06';

% epoch = '2015-01-00';
% originally had these like 2015-01-01 but then I was consistently 24 hours
% off...so just be careful with this adjustment. 
epoch = datetime(2015,01,00,00,00,00);
% epoch = datetime(2016,01,00,00,00,00);


%% TURN .FSDT into a .mat file
species = 'FSDT';

file = [path daterange '\RealTime_Run.' species];
formatSpec = '%f%f%f%f%f%f%f%f%f'; %[^\n\r]';

fid = fopen(file,'r');
data = textscan(fid, formatSpec,'Delimiter', '\t','EmptyValue' ,NaN,...
    'ReturnOnError', false,'MultipleDelimsAsOne',1);
fclose(fid);

c3dtime = data{1,1}; % this is seconds from the beginning of the year
time = datetime(c3dtime,'ConvertFrom','epochtime','Epoch',epoch);
phone = data{1,2};
unk1 = data{1,3};
unk2 = data{1,4};
unk3 = data{1,5};
unk4 = data{1,6};
unk5 = data{1,7};
unk6 = data{1,8};
unk7 = data{1,9};

whale = table(time,c3dtime,phone,unk1,unk2,unk3,unk4,unk5,unk6,unk7);
varname = genvarname(species);
eval([varname '= whale;']);

save([path daterange '\' species '.mat'],varname);
clearvars -except path daterange epoch

%% MINKES MKDT
species = 'MKDT';

file = [path daterange '\RealTime_Run.' species];
formatSpec = '%f%f%f%f%f%f%s'; %[^\n\r]';

fid = fopen(file,'r');
data = textscan(fid, formatSpec,'Delimiter', '\t','EmptyValue' ,NaN,...
    'ReturnOnError', false);
fclose(fid);

c3dtime = data{1,1}; % this is seconds from the beginning of the year
time = datetime(c3dtime,'ConvertFrom','epochtime','Epoch',epoch);
phone = data{1,2};
unk1 = data{1,3};
unk2 = data{1,4};
unk3 = data{1,5};
unk4 = data{1,6};
snippet = data{1,7};

whale = table(time,c3dtime,phone,unk1,unk2,unk3,unk4,snippet);

varname = genvarname(species);
eval([varname '= whale;']);

save([path daterange '\' species '.mat'],varname);
clearvars -except path daterange epoch


%% .BWDT file is different - but I don't want to do this one right now anyway
species = 'BWDT';
file = [path daterange '\RealTime_Run.' species];
formatSpec = '%f%f%f%f%f%s%f%f'; %[^\n\r]';

fid = fopen(file,'r');
data = textscan(fid, formatSpec,'Delimiter', '\t','EmptyValue' ,NaN,...
    'ReturnOnError', false);
fclose(fid);

c3dtime = data{1,1}; % this is seconds from the beginning of the year
time = datetime(c3dtime,'ConvertFrom','epochtime','Epoch',epoch);
phone = data{1,2};
unk1 = data{1,3};
unk2 = data{1,4};
unk3 = data{1,5};
snippet = data{1,6};

whale = table(time,c3dtime,phone,unk1,unk2,unk3,snippet);

varname = genvarname(species);
eval([varname '= whale;']);

save([path daterange '\' species '.mat'],varname);
clearvars -except path daterange epoch

%% merge the datasets across the date ranges

species = {'BWDT','MKDT','FSDT'};
dateranges = {'2015_1221-27', '2015_1227-31', '2016_0103-06'};

for f = 1:length(species)
    whale = table;
    for g = 1:length(dateranges)
        temp = load([path dateranges{g} '\' species{f} '.mat']);
        whale = [whale; temp.(species{f})];
    end
    
    varname = genvarname(species{f});
    eval([varname '= whale;']);

    save([path '\' species{f} '_merged.mat'],varname);
end

%% merge the glider tracks...
% or just start with the ones I already have - but make sure they are .mat files. 

path = 'I:\score\2015\profiles\';
instruments = {'q001', 'q002', 'sg158'};

for f = 1:length(instruments)
    t = readtable([path instruments{f} '_SCORE_Dec15\' instruments{f} '_SCORE_Dec15_locCalc.csv']);
    
    varname = genvarname(instruments{f});
    eval([varname '=t;']);
    
    save(['i:\score\2015\c3d\' instruments{f} '_locCalc.mat'],varname);
end

% check by plotting
plot(q001.lon,q001.lat)
hold on
plot(q002.lon,q002.lat)
plot(sg158.longitude,sg158.latitude)

% these are good to go. 



%% OK NOW ON TO A WHALE SPECIES

% Will start with fins....
% Raw data is in two types of files:
%   the .FSDT files are every individual detection, and I merged those across the sampling period
%       thats the FSDT_merged.mat
%   then the trackFinSei.dat file
%       need to read this in to matlab
% this file is created each time you run the c3d program, so I ran each of
% the time periods independently then saved the .dat file with the date
% range (by hand).

% then i need to merge them. 
% file format is: time(sec from start of year), lat, lon, depth (always
% 150) num hydros, least squares, hydro(time from localization time??)
% For now - I only care about the first 6 columns 

% tables are TrackFinSei1, TrackFinSei2, TrackFinSei3

% fix c3dtime to regular time on the first two
epoch = datetime(2015,01,00,00,00,00);
TrackFinSei1.time = datetime(TrackFinSei1.c3dtime,'ConvertFrom','epochtime','Epoch',epoch);
TrackFinSei2.time = datetime(TrackFinSei2.c3dtime,'ConvertFrom','epochtime','Epoch',epoch);

epoch = datetime(2016,01,00,00,00,00);
TrackFinSei3.time = datetime(TrackFinSei3.c3dtime,'ConvertFrom','epochtime','Epoch',epoch);

finTracks = [TrackFinSei1;TrackFinSei2;TrackFinSei3];

save('i:\score\2015\c3d\finTracks.mat','finTracks');

%% Use Fin Locations on greater than 8 hydrophones 
%
%(increase likelihood its a GOOD hit)
% greater than 5 gave 40980 locs
% great than 8 reduces it to? 23812

finTracks8 = table;

for f = 1:height(finTracks);
    if finTracks.phones(f) > 7
        finTracks8 = [finTracks8; finTracks(f,:)];
    end
end

save('i:\score\2015\c3d\finTracks8.mat','finTracks8');

    scatter(finTracks8.lon,finTracks8.lat,2,datenum(finTracks8.time),'filled')
% that definitely reduces the "chatter"

%% next, look for 'isolated' events and remove them. 
%
% look at time and distance. Time first - greater than 5 min between 
n=0;
index = [];
for f = 2:(height(finTracks8)-1)
    loc = f; 
    before = f-1;
    after = f+1;
    if datenum(finTracks8.time(after))-datenum(finTracks8.time(loc)) > (5*60)/86400 ...
        && datenum(finTracks8.time(loc))-datenum(finTracks8.time(before)) > (5*60)/86400; % 5 mins.
index = [index;f];
        n=n+1;
    end
end
% 74 instances of localizations without anything before or after 5 mins.
% Remove those
% 5 mins only does 74, so make a histogram to see where to make the break

timesbetween = [];
for f = 2:height(finTracks8)
t = datenum(finTracks8.time(f))-datenum(finTracks8.time(f-1));
t = t*86400/60;
timesbetween = [timesbetween; t];
end
histogram(timesbetween,8000)
xlim([-2 10]) 
% has very long tail with max at 3660, but most values are less than 1. 

%redo isolation exclusion using 2 mins

n=0;
index = [];
for f = 2:(height(finTracks8)-1)
    loc = f; 
    before = f-1;
    after = f+1;
    if datenum(finTracks8.time(after))-datenum(finTracks8.time(loc)) > (2*60)/86400 ...
        && datenum(finTracks8.time(loc))-datenum(finTracks8.time(before)) > (2*60)/86400; % 2 mins.
index = [index;f];
        n=n+1;
    end
end

% that gives me 284 isolated events
finTracks8(index,:) = [];
finTracks8h2m = finTracks8;
save('i:\score\2015\c3d\finTracks8h2m.mat','finTracks8h2m');

scatter(finTracks8h2m.lon,finTracks8h2m.lat,2,datenum(finTracks8h2m.time),'filled')

%% WHAT ABOUT DISTANCE ISOLATED EVENTS

E = referenceEllipsoid('wgs84'); % puts it in meters
dist = [];

for f = 2:height(finTracks8h2m);
[arclen,az] = distance(finTracks8h2m.lat(f),finTracks8h2m.lon(f),...
    finTracks8h2m.lat(f-1),finTracks8h2m.lon(f-1),E);
dist = [dist; arclen];
end
min(dist)
max(dist)
median(dist)
histogram(dist,100)
% based on histogram, going to cut off at 2 km

% so repeat dist calc both before and after
index = [];
n = [];

for f = 2:height(finTracks8h2m)-1
    loc = [finTracks8h2m.lat(f) finTracks8h2m.lon(f)];
    before = [finTracks8h2m.lat(f-1) finTracks8h2m.lon(f-1)];
    after = [finTracks8h2m.lat(f+1) finTracks8h2m.lon(f+1)];
    [bDist, bz] = distance(before,loc,E);
    [aDist, az] = distance(after,loc,E);
    if aDist > 2000 && bDist > 2000
    index = [index;f];
        n=n+1;
    end
end

% 2 km cutoff wipes out 6050 instances. 
finTracks8h2m(index,:) = [];
finTracks8h2m2k = finTracks8h2m;
save('i:\score\2015\c3d\finTracks8h2m2k.mat','finTracks8h2m2k');

scatter(finTracks8h2m2k.lon,finTracks8h2m2k.lat,2,datenum(finTracks8h2m2k.time),'filled')


% getting closer - this has more defined tracks I think I can work with
% better

%% Now create my own snapshots??














