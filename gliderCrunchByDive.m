function r = gliderCrunchByDive(sp, ann, dive, calc, pam)      %#ok<INUSL>

nAnn = length(ann);		% number of annotations
nDive = length(dive.dive);	% number of dives total
nDivePamOn = length(pam.dive);	% number of dives when PAM was on

% Set up r, the struct array that gets returned. r is indexed by dive number.
r = struct(...
    'diveNum',		num2cell(1:nDive),...	% need this to make r big enough
    'startTime',	[], ...
    'endTime',		[], ...
    'midLat',		[], ...
    'midLon',		[], ...
    'midTime',		[], ...
    'diveDur',      [], ...  % added by sf 6/19
    'pamOnSec',		[], ...
    'spPresentSec',	[], ...
    'fracPresent',	[]);
    

% Initialize fields in r: iterate through 'dive' struct array by dive number.
% Some fields in r are initialized to 0 so that if PAM is off for that dive,
% the correct value (namely 0) is there.
for di = 1 : nDive
  r(di).startTime    = dive.startTime(di);	% datenum format
  r(di).endTime      = dive.endTime(di);		% datenum format
  r(di).midTime      = (dive.startTime(di) + dive.endTime(di)) / 2; % datenum fmt
  r(di).midLat       = dive.midLatitude(di);
  r(di).midLon       = dive.midLongitude(di);
  r(di).diveDur      = (dive.endTime(di)-dive.startTime(di))*24; % added by sf 6/19
  r(di).pamOnSec     = 0;
  r(di).spPresentSec = 0;
  r(di).fracPresent  = 0;
end

% For each dive in which PAM was on, calculate total time that species sp was
% annotated.
for di = 1 : nDivePamOn
  tTotal = 0.0;		% time (in days) in this dive when species sp is present
  for ai = 1 : nAnn
    % Check whether this annotation overlaps this dive.
    if (ann(ai).t1 >= pam.onTime(di) && ann(ai).t0 <= pam.offTime(di))
      % Check whether this ann has the right species.
      if (gliderSpeciesMatch(ann(ai).species, sp.abbrev))
	% Found a match! Accumulate the time in this dive that this species
	% is present. NOTE that tTotal is in days, not seconds.
	tTotal = tTotal + ...
	    min(ann(ai).t1, pam.offTime(di)) - max(ann(ai).t0, pam.onTime(di));
      end
    end
  end
  
  % Assemble result.
  ri = pam.dive(di);
  r(ri).pamOnSec = pam.durSec(di);
  r(ri).spPresentSec  = tTotal * 24*60*60;
  r(ri).fracPresent = r(ri).spPresentSec / r(ri).pamOnSec;
end
