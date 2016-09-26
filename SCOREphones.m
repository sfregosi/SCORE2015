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

%% Plot them
load([path 'phones.mat']);

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