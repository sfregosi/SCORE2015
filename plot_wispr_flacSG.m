%
% matlab script to plot wispr flac data to read SG607 QUTR test data and
% SCORE 2015.
% We found that wispr program reversed the g0 and g1 pins.   
% Gain  Actual gain
%   0       0 dB
%   1      12 dB
%   2       6 dB
%   3      18 dB
% Uses matlab flac toolbox found at:
% http://www.mathworks.com/matlabcentral/fileexchange/10118-vorbis-flac-audio-encoding-decoding
%

clear all;
%[file, dpath, filterindex] = uigetfile('M:/QUTRSG607/*.flac', 'Pick a flac file');
[file, dpath, filterindex] = uigetfile('M:\SCORE2015SG158\*.flac', 'Pick a flac file');
name = fullfile(dpath,file);
%To read the gain of the WISPR
%f3Dpath=fopen('C:\Users\matsumot\Documents\My Current Research\LMR2014_17\SCORE2015\SG158\SG158_3DPath.txt','r');
% read flac file
%[sig, fs, bps, tag_info] = flacread(name);
info = audioinfo(name);
[sig, fs] = audioread(name);

%SN = input('Enter SN: ');

vref = 5.0;
bitshift = 8;
q = 1; % no rescaling

sig = vref * sig;
avg=mean(sig);
sig=sig-avg; %remove DC

% time vector
time = (1:length(sig))/fs;
time = time*1e6; % usecs

nsamps = length(sig);

% plot time series
clf;
figure(1); 
mlast=1024*1024;
m = 1:mlast;
%subplot(3,1,1);
plot(time(m), sig(m));
axis([time(1) time(mlast) -vref vref]);
ylabel('Volts');
xlabel('Time (usec)');
str = sprintf('WISPR Time Series, Vpp = %f Volts', max(sig) + max(-sig));
title(str);
grid on;

% Welch Spectrogram
%figure(2); clf;
%subplot(3,1,2);
fact=10;
freq_res=50; %Hz
window=fs/freq_res;
noverlap=window/2;
%window=2000;  %freq resolution=fs/2000
%noverlap=1000;
x = sig(1:nsamps/fact);
h = spectrum.welch('Hann',window, 100*noverlap/window);                       % Create a Welch spectral estimator.
hpsd=psd(h,x,'Fs',fs);               % Calculate and plot the one-sided PSD.
%hpsd = psd(h,x,'ConfLevel',0.9);    % PSD with confidence level
figure(2); plot(hpsd);
str = sprintf('Welch Power Spectral Density Estimate');
title(str);grid on;

%Raw FFT
nfft=2^nextpow2(length(x));
ratio=length(x)/nfft;
%ratio=1;
%Pxx=2.*abs(fft(y,nfft)/length(y)).^2;

Pxx=2*ratio*abs(fft(x,nfft)/length(x)).^2; %FFT
enrg=sum(Pxx(1:length(x)/2-1));

%Normalize FFT per Hz
OneHzBin=(length(Pxx)/2-1)/fs;%number of bins per Hz
L=fix(OneHzBin);

Hpsd=dspdata.psd(L*Pxx(2:length(Pxx)/2),'Fs',fs);%Power spec density (ALL)
%plot(Hpsd);

%Normalize in 1 Hz bin
%subplot(3,1,3);
k=0;
for j=1:L:length(Pxx)/2-L;
    k=k+1;
    smPxx(k)=sum(Pxx(j:j+L-1));
end
%adjust the power because 1-Hz bin size is not exactly 1 Hz.
smPxx=smPxx * OneHzBin/L;
km=k;
inc_f=fs/2/(km-1);
for k=1:km
    frq(k)=inc_f*(k-1);
end

Psp=10*log10(smPxx);
figure(3); plot(frq,Psp);
axis([0 fs/2 -100 -40]);
strn=sprintf('FFT power spectral density, Total Energy = %f V^2', enrg);
ylabel('Spectrum Level in dB re 1V ^2/Hz');
xlabel('Frequency [Hz]');
title(strn);
grid on;

%nfft = 1024;
%noverlap = 512;
%win = hanning(nfft);
%spectrogram(sig(1:nsamps/10), win, noverlap, nfft, fs, 'yaxis');

%Remove the system response of Seaglider 607
FrqSys= [1   2   5   10   20    50   100   200  500  1000 2000 5000 10000 20000 30000 40000 50000 60000 62500 64500 70000 80000 90000 100000 110000 120000];
%EOS HM1 pre-amp gain (SG158) single ended gain
PAGain= [-2.3  1.6 7.6 11.5 13.6 14.6 14.8 15.3 17.7 21.4 26.4 33.4  38.3  41.6  42.5  42.8  42.8  42.7 42.7  42.6  42.5  42.3  41.9   41.6   41.2   40.8 ]
%PAGain= [-12.0 -6.0 0.8 4.7 6.9 7.8 8.3 8.8 11.5 15.5 20.7 27.8 32.7  35.9  36.7  37.1  37.1  37.0  36.9  36.8  36.7  36.6  36.2  35.9   35.5   35.1];
%WBPA (OSU) pre-amp gain (SG607)
%PAGain= [-10.0 -2.1 5.9 10.1 12.4 13.4 13.8 14.2 16.7 20.4 25.5 32.8 38.   41.9  42.5  43.2  43.7  43.7  43.6  43.5  43.3  43.2  42.8  42.5   42.    41.7];
%PAGain=PAGain+6; %Differential gain

AntAli= [0      0   0   0   0   0   0   0    0   0    0    0    0     0     0     0     0     -5    -15   -40   -108  -108  -108  -108   -110   -112];
%Hyd-highpass=f/fc/SQRT(1+(f/fc)^2)
%Seaglider HTI92 hydrophone with one-pole 25 Hz high pass
HP25 = [-28   -22 -14 -8.6 -4  -1 -0.3 -0.06 0   0    0    0    0     0     0     0      0     0     0      0     0     0      0     0     0      0];
%Seaglider HTI92 hydrophone with one-pole 50 Hz high pass
HP50 =  [-34  -28 -20 -14  -8.6 -3  -1  -0.3 0   0    0    0    0     0     0     0      0     0     0      0     0     0      0     0     0      0];
HydHP = HP50;
PAGainI=interp1(FrqSys,PAGain, frq,'pchip'); %interpolate
AntAliI=interp1(FrqSys,AntAli, frq,'pchip'); %interpolate
HydHPI=interp1(FrqSys,HydHP, frq,'pchip'); %interpolate

for k=1:length(frq)
    if isnan(AntAliI(k))
        AntAliI(k)=0.;
    end
end

%acq.hydrosens=-165; %This depends on the hydrophone
acq.hydrosens=-175; %This depends on the hydrophone

acq.gain=input('What is the system gain setting? ');
%Y=input('Is this 2015 SCORE data? ', 's');
Y='y';
if (Y == 'y' || Y == 'Y')
    if acq.gain== 1
        acq.gain=2;
    elseif acq.gain == 2
        acq.gain = 1
    end
end
%acq.ga
in=1;         %Changes time to time

SysSens=acq.hydrosens+HydHPI+PAGainI+AntAliI+acq.gain*6;
figure(4); plot(frq, SysSens);
strn=sprintf('System sensitivity');
ylabel('System Sensitivity in dB re 1V/\muPa');
xlabel('Frequency [Hz]');
title(strn);grid on;
%SysSens=acq.hydrosens+PAGainI+AntAliI;

SGNoise=Psp-SysSens;
SmSGNoise=moving_average(SGNoise,10);
figure(5); plot(frq,SGNoise,'.', frq, SmSGNoise,'-');

set(gca,'XScale','log');
axis([1 fs/2 20 140]);
%strn=sprintf('SG607 noise spectral density %s', name);
strn=sprintf('SG158 noise spectral density %s', name);
ylabel('Spectral Level in dB re 1\muPa^2/Hz');
xlabel('Frequency [Hz]');
title(strn);
grid on;
%par(new=TRUE);
%plot(frq,SmSGNoise);
%fclose(f3Dpath);

