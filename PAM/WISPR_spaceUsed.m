% Glider PAM data storage used

clear all
gldr = 'sg607';

path = ['C:\Users\sfreg_000\SkyDrive\gliders_local\AFFOGATO\'...
    '2016_07_CatBasin\sg607\extractedFiles\'];

URL = ['http://gliderfs2.coas.oregonstate.edu/sgliderweb/seagliders/'...
    gldr '/current/basecopy/'];

basestationFileExtract(gldr,path,URL)

files = dir([path '*.r']);
PAMstats=struct(...
    'diveNum',  [],...
    'writeTime',[],...
    'totalTime', [],...
    'maxDepth', [],...
    'freeSpace', []);

for f = 1:length(files)
    if files(f).bytes==0;
        disp([files(f).name ' is empty']);
    else
        [diveNum writeTime totalTime maxDepth freeSpace] = affogatoPAMRead([path files(f).name]);
    end
    PAMstats.diveNum=[PAMstats.diveNum diveNum];
    PAMstats.writeTime = [PAMstats.writeTime writeTime];
    PAMstats.totalTime = [PAMstats.totalTime totalTime];
    PAMstats.maxDepth = [PAMstats.maxDepth maxDepth];
    PAMstats.freeSpace = [PAMstats.freeSpace freeSpace];
end

plot(PAMstats.diveNum,PAMstats.freeSpace,'.')
xlabel('DiveNum')
ylabel('Free Space (%)')

print('-dpng', [path 'PAMspaceUsed.png']);
