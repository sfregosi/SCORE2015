function c = gliderCrunchByCall(sp, ann, dive, calc)  %#ok<INUSD>
%gliderCrunchByCall	process each call to get the closest glider location at
%the start of the call
% this is good for baleen whales where EACH call has been marked as an
% annotation....otherwise not very useful...
%'annNum,annStartTime,annEndTime,annLat,annLon,annDepth,dive'

%% Set up c, the struct array that gets returned. e has one entry per 
% call of the desired species.

c = struct(...
    'startTime', [], ...
    'endTime',	 [], ...
    'lat',       [], ...
    'lon',       [], ...
    'depth',     [], ...
    'dive',      [] ...
    );

nAnn = length(ann);		% number of annotations/encounters
diveStartTime = dive.startTime;
%% Check each annotation/encounter to see if it's the right species. 
% If so, append it to c.
ci = 0;
for ai = 1 : nAnn
  % Check whether this ann/enc has the right species.
  if (gliderSpeciesMatch(ann(ai).species, sp.abbrev))
    % Yes! Add it to the output struct array c.
    ci = ci + 1;
    c(ci).startTime = ann(ai).t0;				% datenum format
    c(ci).endTime   = ann(ai).t1;				% datenum format
    
    % Choose the diveNum as the dive whose start time is the closest time
    % in the past to this
    [~,d] = min(abs(c(ci).startTime - diveStartTime));
    c(ci).dive  = d;
    
    % Choose the locCalc entry/time just before the start time of this call
    i0=find(calc.time <= c(ci).startTime,1,'last');
    c(ci).lat = calc.latitude(i0);
    c(ci).lon = calc.longitude(i0);
    c(ci).depth = calc.depth(i0);
  end
end
