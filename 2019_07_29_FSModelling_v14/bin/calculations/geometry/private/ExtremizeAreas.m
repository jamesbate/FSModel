function results = ExtremizeAreas(geometry, sections)
% Find all the extremal areas by optimizing each negative topology section.
%
% This is quite a sophisticated thing, but its essence is extremization
% over those intervals.
%
% This is conservative with the number of function evaluations but does
% do linear probes into 'walking descend' and zooms further if it finds
% discontinuities close to each other.

results = {};
for ind = 1:length(sections)
    
    % This copy is important and subtle.
    % s will be linked to the sections entry because it is under the hood
    % pointer arithmetic. So if the s.alpha/beta are changed,
    % then so will sections. You do not want to adjust the user's
    % version of sections like that so make a copy to break the reference.
    s = CopyStruct(sections{ind});
    if isempty(s.topology) || s.topology(1) >= 0
        continue;
    end
    
    [aa, bb, areas] = ExtremizeNonLinearEval(geometry, s, 50);    
    stats = ExtremizeClassifyAll(areas);
    results = ExtremizeAddResults(results, geometry, aa, bb, stats, areas);
    results = ExtremizeLaunchInvestigations(results, geometry, aa, bb, areas);
end
results = RemoveTerribleOnes(results);
end %ExtremizeAreas


function s2 = CopyStruct(s1)
% Make a shallow copy of this struct.
for fn = fieldnames(s1)'
   s2.(fn{1}) = s1.(fn{1});
end 
end %CopyStruct


function results = RemoveTerribleOnes(results)

maxi = 0;
for ind = 1:length(results)
    maxi = max([maxi, results{ind}.area]);
end

keep = ones(1, length(results)) == 1;
for ind = 1:length(results)
    if results{ind}.dArea >= results{ind}.area * 0.7
        keep(ind) = false;
        fprintf('Removing extremum %.3e +- %.3e, too weird.\n', ...
                results{ind}.area, results{ind}.dArea);
    elseif results{ind}.dArea == 0 && results{ind}.area < 0.01 * maxi
        keep(ind) = false;
        fprintf('Removing extremum %.3e, it has no uncertainty and is relatively small.\n', ...
                results{ind}.area);
    end
end
results = results(keep);

end
