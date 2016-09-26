%quanitify total recording hours for glider and quephones
clear all

gldr='sg158';
path=['D:\score\2016\data\' gldr '-HF-125kHz\'];
cd(path);

% find all raw acoustic files
files=dir([path '\*.wav']);
shortfiles=[];

% calc duration in sec using sampling rate..slow but works
for f=1:length(files); % started at 4406 bc thats where it failed
    [y,Fs]=audioread([path files(f,1).name]);
    files(f,1).dur=length(y)./Fs;
    if length(y)~=9994240;
        shortfiles=[shortfiles; f length(y)];
        disp(length(y));
        disp(files(f,1).name);
    end
    clear y Fs
    if rem(f,1000)==0;
        disp([num2str(f) ' DONE']);
    end
end

totdur=0;
for g=1:length(files);
    totdur=totdur+files(g,1).dur;
end

totdurhour=totdur/3600;

save(['C:\Users\sfreg_000\SkyDrive\gliders_local\AFFOGATO\2015_12_SCORE\' ...
    gldr '_PAMdur.mat'],'files','shortfiles','totdur','totdurhour')

