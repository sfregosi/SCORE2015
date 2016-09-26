% PLOTTING EVERYTHING
path = 'i:\score\2015\c3d\';

% choose what to turn off/on
plotPhones = true;
plotTracks = true;
plotFins = true;


%% Phones
if plotPhones
load([path 'phones.mat']);

h = figure;
ax = gca;
% daspect([1 1.18 1])
% % PlotBoxAspectRatio, [1 1.18 1])
axis vis3d
scatter(phones.lon,phones.lat,25,'filled');
% scatter(phones.lon,phones.lat,25,phones.depth,'filled'),colorbar;
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
end
%% Tracks
if plotTracks
load([path 'q001_locCalc.mat']);
load([path 'q002_locCalc.mat']);
load([path 'sg158_locCalc.mat']);

plot(q001.lon,q001.lat)
plot(q002.lon,q002.lat)
plot(sg158.longitude,sg158.latitude)
end

%% Fins
if plotFins
    load([path 'finTracks8.mat']);
    scatter(finTracks8.lon,finTracks8.lat,2,datenum(finTracks8.time),'filled')
end
