% Working with SPAWAR SCORE baleen data from c3d program

% see notes on file formats, etc

% goals are to take their data files and make into .mat, adjust timing so I
% can work on them in here, and look at all data at once

% for now ignore beaked whales (will get those from NUWC)
clear all

addpath('i:\score\2015\matlab\');
path='i:\score\2015\c3d\';
cd(path);

%% TURN HYDROPHONE LOCATIONS INTO A .mat FILE

file = [path '\c3d-software\c3d x64\c3d\phone_ref.txt'];
formatSpec = '%f%f%f%f%f%f%s';
fid = fopen(file,'r');

data = textscan(fid, formatSpec, 'Delimiter', '\t');
fclose(fid);

phones = table;
phones.num = data{1,1};
phones.phone = data{1,2};
phones.lat = data{1,4};
phones.lon = data{1,5};
phones.depth = data{1,6};
save([path 'phones.mat'],'phones');

h = figure;
ax = gca;
% daspect([1 1.18 1])
% % PlotBoxAspectRatio, [1 1.18 1])
axis vis3d
scatter(phones.lon,phones.lat,25,phones.depth,'filled'),colorbar;
text(phones.lon+0.005,phones.lat+0.005,num2str(phones.phone));
ax.PlotBoxAspectRatio = [1 1.18 1];
hold on

% Draw a scale bar. lenKm says how many kilometers long it is.
lenKm = 2;
xt = get(gca, 'XTick'); ixt = floor(length(xt)/2);
yt = get(gca, 'YTick');
xlen = lenKm * 1000 / 1852 / 60 * sec(min(yt) * pi / 180);
set(plot(xt(ixt) + [0 xlen], min(yt)+ [0.05 0.05], 'k-'), 'LineWidth', 3)
text(xt(ixt) + xlen/2, min(yt)+0.05, sprintf('%d km', lenKm), ...
    'Horiz', 'cen', 'Vert', 'Top', 'Color', 'k', 'FontWeight', 'bold');
hold off

% % do i need to project it more accurately?
% % decided NO...it looks funny
% mstruct = defaultm('tranmerc')
% [x,y] = projfwd(mstruct,phones.lat,phones.lon)
% figure
% scatter(y,x,25,phones.depth,'filled')

%% TURN .FSDT into a .mat file
daterange = '2015_1221-27';
epoch = '2015-01-01';

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
clearvars time c3dtime phone unk1 unk2 unk3 unk4 unk5 unk6 unk7

varname = genvarname(species);
eval([varname '= whale;']);

save([path daterange '\' species '.mat'],varname);

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
clearvars time c3dtime phone unk1 unk2 unk3 unk4 snippet

varname = genvarname(species);
eval([varname '= whale;']);

save([path daterange '\' species '.mat'],varname);



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
clearvars time c3dtime phone unk1 unk2 unk3 snippet

varname = genvarname(species);
eval([varname '= whale;']);

save([path daterange '\' species{f} '.mat'],varname);

















