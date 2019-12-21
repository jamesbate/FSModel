function [top,a2,b2,top3,a3,b3] = CoverageNextCycle(geometry, nodesA, nodesB, a, b, angle)
% Given a point, walk in angle direction to find the edge of this
% topological region.
%
% top,a2,b2  : the CoverageTopology matching (a,b) as well as (a2,b2) 
%              and a point that is just inside this region still.
% top3,a3,b3 : the next CoverageTopology matching (a3,b3)
%              and a point that is just over the edge.
%              
% Note: It costs extra computational time to find top3/a3/b3, but if you
% take them you can feed them right back in here for the next edge along
% the same line.


% First find out what the movement direction is
dA = cos(angle);
dB = sin(angle);

% Find out the CoverageTopology to find the edge of.
% You cannot find the edge of a region of ill defined orbits,
% that is asking for trouble.
baseTopo = CoverageTopology(geometry, a, b, nodesA, nodesB);
if isempty(baseTopo)
    error('%s%s.', ...
          'Should start at a zero orbit or a stable one inside a ', ...
          'limit cycle, not a divergent orbit.');    
end

% Exponentially zoom out/in to get closer to the border,
% At the end, off is inside the region, but doubling it would put 
% you outside the region. Meaning the scale is determined.
off = 0.1;
propTopo = CoverageTopology(geometry, a+off*dA, b+off*dB, nodesA, nodesB);
if isequal(propTopo, baseTopo)
    while isequal(propTopo, baseTopo)
        off = off*2;
        propTopo = CoverageTopology(geometry, a+off*dA, b+off*dB, nodesA, nodesB);
    end
    off = off/2;
else
    while ~isequal(propTopo, baseTopo)
        off = off/2;
        propTopo = CoverageTopology(geometry, a+off*dA, b+off*dB, nodesA, nodesB);
    end
end

% Then the second step is to exponentially increase the accuracy
% by scaling down the uncertainty from (off: -0 +off) to (off: -0, +1e-4)
delta = off;
while delta > 1e-4
    newOff = off + delta/2;
    nextTopo = CoverageTopology(geometry, a+newOff*dA, b+newOff*dB, nodesA, nodesB);
    if isequal(baseTopo, nextTopo)
        off = newOff;
    end
    delta = delta/2;
end

% The first half of the output is now known
top = baseTopo;
a2 = a+off*dA;
b2 = b+off*dB;
if nargout < 4
    return;
end

% The second half is still to be done.
% First establish a new non-empty CoverageTopology.
% Notice that this is NOT 'is contained in', but just 'nonempty'.
% It is possible to lose the original orbit, e.g. when you 
% have a double cusp and move in between rather than away.
% The former means you lose the base, the latter you expand.
%
% off2 is expected to be within the nextTopo region.
% i.e. where off was 'always too small', off2 is 'always too large'.
% The undefined region in between where possible discontinuities arise,
% is being pinched to a minimum.
%
% This was changed to also include isequal(next,now) because instability
% makes it so that this cannot be definitively marked as the one and 
% only endpoint.
off2 = 0.01;
nextTopo = CoverageTopology(geometry, a2+off2*dA, b2+off2*dB, nodesA, nodesB);
if isequal(nextTopo, baseTopo)|| isempty(nextTopo)
    while (isempty(nextTopo) || isequal(nextTopo, baseTopo)) && off2<10
        off2 = off2*2;
        nextTopo = CoverageTopology(geometry, a2+off2*dA, b2+off2*dB, nodesA, nodesB);
    end
    
    if off2 >= 10
        
        disp(nodesA);
        disp(nodesB);
        disp([a,b]);
        disp([a2,b2]);
        disp(basTopo);
        disp(nextTopo);
        
        error('Could not find a new topological region distinct from (%.3f,%.3f).', ...
              a,b);
    end
    
    delta2 = off2/4;
else
    delta2 = off2/2;
end


% Then again fine-tune the position.
% This time from off2 (-delta +0) to (-1e-6 +0)
while delta2 > 1e-6
    newOff = off2 - delta2/2;
    propTopo = CoverageTopology(geometry, a2+newOff*dA, b2+newOff*dB, nodesA, nodesB);
    if ~isempty(propTopo) && ~isequal(propTopo, baseTopo)
        off2 = newOff;
        nextTopo = propTopo;
    end
    delta2 = delta2/2;
end

top3 = nextTopo;
a3 = a2+off2*dA;
b3 = b2+off2*dB;
end
