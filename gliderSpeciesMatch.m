function hit = gliderSpeciesMatch(annSp, abbr)
% See if this annotation is the given species. 'annSp' is from a square in an
% annotation .xls file and 'abbr' is one or more species abbreviation(s): a
% single element of the 'abbrev' field of the 'species' struct array. abbr is
% either a string or a cell vector. Some species have multiple abbreviations,
% so check them all. Returns true if it's the same species, otherwise false.

hit = false;
if (~iscell(abbr))		% only 1 abbreviation for this species?
  hit = strcmpi(abbr, strtrim(annSp));
else				% multiple abbreviations for this species
  for i = 1 : length(abbr)
    hit = hit || strcmpi(abbr{i}, strtrim(annSp));
  end
end
