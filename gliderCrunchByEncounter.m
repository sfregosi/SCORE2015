function e = gliderCrunchByEncounter(sp, ann, dive, calc, pam)  %#ok<INUSD>
%gliderCrunchByEncounter	process per-annotation or per-encounter data
%
% NB: The input arg 'ann' might have data about encounters rather than
% annotations. This routine is called once for annotations and once for
% encounters.

%% Set up e, the struct array that gets returned. e has one entry per 
% encounter of the desired species.
%
% NB: Several field names here start with 'ann', but they might have data about
% encounters, not annotations, if the input 'ann' has information about
% encounters.
e = struct(...
    'annStartTime',	[], ...
    'annEndTime',	[], ...
    'annMidTime',	[], ...
    'annDurSec',	[], ...
    'diveNum',		[], ...
    'diveMidLat',	[], ...
    'diveMidLon',	[], ...
    'annMinDepth',	[], ...
    'annMaxDepth',	[] ...
    );

nAnn = length(ann);		% number of annotations/encounters
diveMidTime = (dive.startTime + dive.endTime) / 2;

%% Check each annotation/encounter to see if it's the right species. 
% If so, append it to e.
ei = 0;
for ai = 1 : nAnn
  % Check whether this ann/enc has the right species.
  if (gliderSpeciesMatch(ann(ai).species, sp.abbrev))
    % Yes! Add it to the output struct array e.
    ei = ei + 1;
    e(ei).annStartTime = ann(ai).t0;				% datenum format
    e(ei).annEndTime   = ann(ai).t1;				% datenum format
    e(ei).annMidTime   = (ann(ai).t0 + ann(ai).t1) / 2;		% datenum format
    e(ei).annDurSec    = (ann(ai).t1 - ann(ai).t0) * 24*60*60;	% seconds
    
    % Choose the diveNum as the dive whose mid time is closest to the mid time
    % of this ann/enc.
    [~,d] = min(abs(e(ei).annMidTime - diveMidTime));
    e(ei).diveNum     = d;
    e(ei).diveMidLat  = dive.midLatitude(d);
    e(ei).diveMidLon  = dive.midLongitude(d);
    
    % To get the min and max depths, find all the positions of the glider
    % dead-reckoned every 10 seconds during this encounter, then take the min
    % and max of the depths for those positions.
    i0 = find(calc.time >= e(ei).annStartTime, 1, 'first');
    i1 = find(calc.time <= e(ei).annEndTime,   1, 'last');
    if (i1 < i0), i1 = i0; end		% can happen w/very short annotations
    e(ei).annMinDepth = min(calc.depth(i0:i1));
    e(ei).annMaxDepth = max(calc.depth(i0:i1));
  end
end
