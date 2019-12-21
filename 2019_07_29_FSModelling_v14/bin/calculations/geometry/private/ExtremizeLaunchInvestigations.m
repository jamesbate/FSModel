function results=ExtremizeLaunchInvestigations(results, geometry, aa, bb, areas)
% Take a bunch of results and look for multiple closely spaced 
% discontinuities. If they are found, launch ExtremizeInvestigate
% to look for a result there and let it add it as well if it were found.

stats = ExtremizeClassifyAll(areas);

index = 1;
last2 = 0;
while index <= length(stats)
    if stats(index) ~=2
        index = index + 1;
    elseif last2==0 || index - last2>5
        last2 = index + 1;
        index = index + 2;
    else        
        % If there were multiple points in the region
        % then there are 4 2's and the last one is one place further
        if index < length(stats) && stats(index+1) == 2
            endat = index+1;
            
        % If this is a single spike
        % then there are 3 2's and this is already the last one
        else
            endat = index;
        end
        
        try
            results = ExtremizeInvestigate(results, geometry, ...
                                           aa(last2-1), bb(last2-1), ...
                                       aa(endat), bb(endat));
        catch exc
            figure;
            plot(geometry.CalcDistance(aa,bb),areas);
            
            
            
        end
        last2 = index + 1;
        index = index + 2;
    end
end

end %ExtremizeLaunchInvestigations


function results = ExtremizeInvestigate(results,geometry,a1,b1,a2,b2)
% Make a linear evaluation in this region and add any found extremae.

% Evaluate over a linear segmentation
% Odd number because you want to include the halfway mark which was the
% reason this was selected if you had a 3-point discontinuity
aa = linspace(a1,a2,21);
bb = linspace(b1,b2,21);
areas = zeros(1, length(aa));
for ind = 1:length(aa)
    try
        areas(ind) = geometry.CalcArea(aa(ind), bb(ind));
    catch
        areas(ind) = NaN;
    end
end
dd = geometry.CalcDistance(aa, bb);

% Allow at most 2 values to diverge as some of these not fully stable at
% the discontinuity points. Start with dd because why not, you just cant
% start with areas because you lose the information.
dd(isnan(areas)) = [];
if length(dd) < length(areas) - 4
    return;
end
aa(isnan(areas)) = [];
bb(isnan(areas)) = [];
areas(isnan(areas)) = [];


% Then find and add the extrema.
isMinis = ExtremizeClassifyAll(areas);
results = ExtremizeAddResults(results, geometry, aa, bb, isMinis, areas);

% And the discontinuity is still there and unresolved, then 
% recurse
nrExtr = sum(isMinis==1) + sum(isMinis==0);
nr2s = sum(isMinis==2);
if nrExtr>0 || nr2s > 4
    return;
end
results = ExtremizeLaunchInvestigations(results, geometry, aa, bb, areas);
end %ExtremizeInvestigate
