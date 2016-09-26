function enc = gliderMergeAnnIntoEnc(ann, tMergeSec)
%mergeEncIntoAnn	merge nearby annotations of identical species
%
% Merge annotations as needed, creating encounters. Annotations are merged if
% they are closer together than tMerge seconds. The returned structure 'enc'
% has the same fields as the input structure 'ann'.

nAnn = length(ann);
keep = true(1, nAnn);		% says which elements of ann() to keep
for ai = 1 : nAnn-1
  % Check whether this ann, namely ann(ai), should get merged into another one,
  % namely ann(ix). Here, ix cycles through ixAll, all the indices of anns that
  % are within tMergeSec of ann(ai).
  ixAll = find(ann(ai).t1 >= ([ann(ai+1:end).t0] - tMergeSec/24/60/60)) + ai;
  for ix = ixAll
    % Not only does the time have to be within tMergeSec, but the species must
    % match too.
    if (gliderSpeciesMatch(ann(ai).species, ann(ix).species))
      % Merge this ann into ann(ix), and mark this one for discarding.
      ann(ix).beginDate = ann(ai).startDate;
%       ann(ix).beginTime = ann(ai).beginTime;
      ann(ix).endDate   = ann(ai).endDate;
%       ann(ix).endTime   = ann(ai).endTime;
      ann(ix).t0        = ann(ai).t0;		% don't change ann(ix).t1
%       ann(ix).lowFreq   = min(ann(ai).lowFreq,  ann(ix).lowFreq);
%       ann(ix).highFreq  = max(ann(ai).highFreq, ann(ix).highFreq);
      keep(ai) = false;		% mark ann(ai) for discarding
      break
    end
  end
end

enc = ann(keep);		% discard ones that were merged
