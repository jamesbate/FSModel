function [aa, bb] = CoverageDistributePoints(geometry, sections, amount, nans)
% Distribute *at least* amount points over these sections to cover
% the entire surface of geometry when you follow their orbits.
% The orbits are about equidistant in geometry.CalcDistance,
% except at the discontinuities where they are very closely together 
% to cut off the minimum possible volume.
%
% NaNs means: put a NaN in aa/bb between sections.
% Within each section the ordering is on increasing distance.
aa = [];
bb = [];
width = DistanceCovered(geometry, sections);
for ind = 1:length(sections)
    s = sections{ind};
    [aHere, bHere] = SingleDistribution(geometry, s, width, amount);
    if ~isempty(aHere)
        aa(end+1:end+length(aHere)) = aHere;
        bb(end+1:end+length(bHere)) = bHere;
        if nans && ind < length(sections)
            aa(end+1) = NaN;
            bb(end+1) = NaN;
        end
    end
end %for
end %CoverageDistributePoints


function width = DistanceCovered(geometry, sections)
% Get the minimum and maximum distance and return the difference.
minD = 1e99;
maxD = -1e99;
for ind = 1:length(sections)
    s = sections{ind};
    da = geometry.CalcDistance(s.alpha(1),s.alpha(2));
    db = geometry.CalcDistance(s.beta(1),s.beta(2));
    minD = min([minD, da, db]);
    maxD = max([maxD, da, db]);
end
width = maxD-minD;
end %DistanceWidth

function [aa, bb] = SingleDistribution(geometry, section, width, amount)
% Generate the points necessary to cover this section of the geometry.
%
% Distributes such that width in distance would make for amount points,
% but guarantees at least 5 points in the interval if the topology is
% not empty, in which case aa and bb are empty. Really in essence
% a linear space between section.alpha and section.beta, linear 
% in distance (as opposed to linear in ab space). 
% The crucial aspect is how many points you take.
% topology -1 is limited to 20 and 30% of amount from below.

if isempty(section.topology)
    aa=[];
    bb=[];
    return;
end

A = section.alpha;
B = section.beta;
da = geometry.CalcDistance(A(1), A(2));
db = geometry.CalcDistance(B(1), B(2));

if width == 0
    nr = amount;
else
    nr = max([5, ceil(abs(da-db)/width*amount)]);
end
if ~isempty(section.topology) && section.topology(1) < 0
    nr = max([nr, 20, floor(0.3*amount)]);
end

aa = linspace(A(1), B(1), nr);
bb = linspace(A(2), B(2), nr);
dd = geometry.CalcDistance(aa, bb);

if da ~= db
    dd2 = linspace(min([da,db]), max([da,db]), nr);
    filter = ceil(length(aa) / 10);
    
    for ind = 2:length(aa)-1
        [~, id] = min(abs(dd - dd2(ind)));        
        aa0 = [aa(id), aa(1:filter:end)];     
        bb0 = [bb(id), bb(1:filter:end)];
        
        [aa(ind),bb(ind)] = geometry.FindPlane(dd2(ind),aa0, bb0);
        dd(ind) = geometry.CalcDistance(aa(ind),bb(ind));
    end    
end

[~, order] = sort(dd);
aa = aa(order);
bb = bb(order);
end %SingleDistribution
