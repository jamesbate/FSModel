function [aa, bb, areas] = ExtremizeNonLinearEval(geometry, section, amount)
% Evaluate a number of areas non linearly in between the points given 
% by this section's .alpha and .beta.
%
% Distributes amount linearly, but then intensify the edges.
%
% Note: it may be sensible to make this linearly spaced in distance
% rather than in (a,b) space, though it should not be necessary.
% Idea for later.


% First do the normal linear evaluation as expected
aa = linspace(section.alpha(1), section.beta(1), amount);
bb = linspace(section.alpha(2), section.beta(2), amount);

% Then make a extra at the edges.
aa = LinspacedEdges(aa, 5);
bb = LinspacedEdges(bb, 5);

% Evaluate the area where possible.
areas = zeros(1, length(aa));
for ind = 1:length(aa)
    try
        areas(ind) = geometry.CalcArea(aa(ind), bb(ind));
    catch
        areas(ind) = NaN;
    end %try
end %for


% Next, consider expanding the edges to be able to find
% extremae if they are there due to symmetry
% think: simply corrugated cilinder along the main axis 
% compare: zero-orbit near a node
if ~isnan(areas(1)) && areas(1) > 0
    localA = 2*aa(1) - aa(2);
    localB = 2*bb(1) - bb(2);
    try
        localArea = geometry.CalcArea(localA, localB);
    catch
        localArea = NaN;
    end
    
    if ~isnan(localArea)
        areas(2:end+1) = areas;
        areas(1) = localArea;
        aa(2:end+1) = aa;
        aa(1) = localA;
        bb(2:end+1) = bb;
        bb(1) = localB;
    end
end

if ~isnan(areas(end)) && areas(end) > 0
    localA = 2*aa(end) - aa(end-1);
    localB = 2*bb(end) - bb(end-1);
    try
        localArea = geometry.CalcArea(localA, localB);
    catch
        localArea = NaN;
    end
    
    if ~isnan(localArea)
        areas(end+1) = localArea;
        aa(end+1) = localA;
        bb(end+1) = localB;
    end
end


% Finally remove the NaNs
aa(isnan(areas)) = [];
bb(isnan(areas)) = [];
areas(isnan(areas)) = [];   

if length(areas) < amount * 0.9
    error('Out of %d planes, %d were found. Too few.', ...
          amount, length(areas));
end


% Make sure the distance is monotonic. 
% This fixes numerical precision issues in some actual cases, 
% where consequently a fake min/max was observed.
% i.e. the rest of the program absolutely relies on monotonic differences
% and this way it is guaranteed.
dd = geometry.CalcDistance(aa, bb);
[~, order] = sort(dd);
if dd(end) < dd(1)
    order = order(end:-1:1);
end
aa = aa(order);
bb = bb(order);
areas = areas(order);

end %ExtremizeNonLinearEvaluation


function arr = LinspacedEdges(arr, extra)
% Add extra points at both ends between the edge and one point off
% of it with linear scaling.

arr(extra+2:end+extra) = arr(2:end);
arr(1:extra+2) = linspace(arr(1),arr(2),extra+2);
arr(end-1:end+extra) = linspace(arr(end-1),arr(end),extra+2);
end %LinspacedEdges



function arr = LogspacedEdges(arr, extra)
% Add extra points at both ends between the edge and one point off
% of it with logarithmic scaling starting at 1000 times smaller intervals.
%
% Decommissioned because it appears extremization really does not like this
% kind of stuff and it is counter intuitive and surprisingly complicated.
error('Out of operation');
arr(extra+2:end+extra) = arr(2:end);

da = abs(arr(2)-arr(1));
lspace(1) = 0;
lspace(2:extra+2) = logspace(log10(da)-3,log10(da),extra+1);
if arr(2) < arr(1)
    lspace = -lspace;
end
arr(1:extra+2) = arr(1) + lspace;

% And the other end

da = abs(arr(end)-arr(end-1));
arr(end+extra) = arr(end);
lspace(1) = 0;
lspace(2:extra+2) = logspace(log10(da)-3,log10(da),extra+1);
if arr(end-extra-1) > arr(end-extra)
    lspace = -lspace;
end

arr(end:-1:end-extra-1) = arr(end-extra) - lspace;


end

