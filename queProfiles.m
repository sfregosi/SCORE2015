% turn QUEphone surface and calcuated data into something that matches
% glider extracted data

clear all
clc
gldr='q001';
lctn='SCORE';
dplymnt='Dec15';

cd(['i:\score\2015\profiles\' gldr '_' lctn '_' dplymnt '\']);


%% gpsSurf
%
% start with a file with the following columns:
% dive startTime startLat startLon endTime endLat endLon
% this will have to be made by hand from all the surfacings, use the start
% time of the next dive as the end time/lat/lon for the previous, deleted
% the last one because it will have the same start and end info. 
%
% import this by hand, as a numeric matrix, call it gpsSurf
% ************** IMPORT HERE *********************

gpsSurf = q002SCOREDec15gpsSurface;
clear q002SCOREDec15gpsSurface;

% It needs to match glider gpsSurf files so need to add:
gpsSurf(:,8) = (gpsSurf(:,5)-gpsSurf(:,2))*24; % duration, in hours
gpsSurf(:,9) = (gpsSurf(:,5)+gpsSurf(:,2))/2; % midtime 
% these mid times and lat/lons are less applicable for the quephone but
% they are important to keep the rows consistent.
% ** in the future maybe convert everything to tables and then they would
% all have consistent variable names so consistent size would be less
% important
gpsSurf(:,10) = (gpsSurf(:,6)+gpsSurf(:,3))/2; % midtime 
gpsSurf(:,11) = (gpsSurf(:,7)+gpsSurf(:,4))/2; % midtime 
gpsSurf(:,12) = ones; % labeledby dive, again an artifact of HDR reports/gliders

% test it by plotting
plot(gpsSurf(:,4),gpsSurf(:,3));
hold on
plot(gpsSurf(:,7),gpsSurf(:,6));
plot(gpsSurf(:,11),gpsSurf(:,10));
hold off

% save it
save(['i:\score\2015\profiles\' gldr '_' lctn '_' dplymnt '\'...
    gldr '_' lctn '_' dplymnt '_gpsSurface.mat'],'gpsSurf');

col_name='Dive,startTime,startLat,startLon,endTime,endLat,endLon,dur(Hr),midTime,midLat,midLon,labeledbydive';
dlmwrite([gldr '_' lctn '_' dplymnt '_gpsSurface.csv'],col_name,'delimiter','');
dlmwrite([gldr '_' lctn '_' dplymnt '_gpsSurface.csv'],gpsSurf,'delimiter',...
    ',','precision','%.6f','-append');

%% locCalc

% start with a file with the following columns:
% dive time lat lon depth PAM
% ********* IMPORT BY HAND *****************
locCalc = q001SCOREDec15locCalc;
clear q001SCOREDec15locCalc

% make zero columns for temparture, salinity and sound velocity between
% depth and PAM
locCalc(:,9) = locCalc(:,6);
locCalc(:,6:8) = zeros(length(locCalc),3);

% plot it to check
plot(locCalc(:,4),locCalc(:,3));
% should look similar to above with a bit more detail

% save it
save(['i:\score\2015\profiles\' gldr '_' lctn '_' dplymnt '\'...
    gldr '_' lctn '_' dplymnt '_locCalc.mat'],'locCalc');

col_name='Dive,time,lat,lon,depth,temp,salinity,soundVel,PAM';
dlmwrite([gldr '_' lctn '_' dplymnt '_locCalc.csv'],col_name,'delimiter','');
dlmwrite([gldr '_' lctn '_' dplymnt '_locCalc.csv'],locCalc,'delimiter',...
    ',','precision','%.6f','-append');




