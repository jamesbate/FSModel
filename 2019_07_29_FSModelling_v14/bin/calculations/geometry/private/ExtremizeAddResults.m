function results = ExtremizeAddResults(results, geometry, aa, bb, isMinis, areas)
% Refine the result and add it to the pile.
%
% Removes all isMinis that are not 0 or 1 for you.
% Refines the optima with WalkingDescend1.

for ind = 1:length(aa)
    % Step 1: Skip (cheap)
    if ~ExtremizeIsInteresting(results, areas(ind), isMinis(ind))
        continue;
    end
    
    % Step 2: Localize
    aloc = aa(ind-1:ind+1);
    bloc = bb(ind-1:ind+1);
    arealoc = areas(ind-1:ind+1);
    
    result = ExtremizeRefine(geometry, aloc, bloc, arealoc, isMinis(ind));
    if ~isstruct(result)
        continue;
    end
    
    % Step 3: Skip (expensive)
    if ~ExtremizeIsInteresting(results, result.area, result.isMini)
        continue;
    end
    results{end+1} = result;
end %for
end %AddResults
