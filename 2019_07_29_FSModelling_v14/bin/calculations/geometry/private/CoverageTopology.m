function [top, path] = CoverageTopology(geometry, a, b, nodesA, nodesB)
% Find the nodes enclosed by this path, return the path as well
% in case you want it and don't want to double compute it.
% 
% Top is empty when the path did not 
% converge and hence the topology could not be determined
% (which really means you are at discontinuity/boundary)
% 
% Top is -1 if the path is not closed in (a,b) space, meaning 
% a breakdown of the topology argument.
%
% When a zero-sized orbit is found, there is a check which node is 
% closest and if it is close enough, that topology is returned.

path = [];
top = [];
try
    path = geometry.CalcPath(a, b, true);
catch exc    
    if strcmp(exc.identifier, 'Marching:Starting')
        distances = zeros(1,length(nodesA));
        for ind = 1:length(distances)
            da = min([mod(nodesA(ind)-a,2*pi), 2*pi-mod(nodesA(ind)-a,2*pi)]);
            db = min([mod(nodesB(ind)-b,2*pi), 2*pi-mod(nodesB(ind)-b,2*pi)]);
            distances(ind) = sqrt(da^2+db^2);
        end
        [minD, maybeTop] = min(distances); 
        if minD < 0.1
            top = maybeTop;
        end
    end
   
   % Crash => 2 empty arrays
   % Zero area at node => path is empty, topology is numerical (1-vector).
   % Zero area no node => 2 empty arrays
   %
   % (the latter is possible at points where distance is a saddle,
   %  example is a double cusp and sitting right in between. This is 
   %  a point actively looked for while escaping while moving straight 
   %  from one point to the next and hence has to be respected)
   return;
end

% If a or b differs by a multitude of 2pi, then wrapping and no topology.
deltaA = path(end,1)-a;
deltaB = path(end,2)-b;
if abs(deltaA) > pi || abs(deltaB) > pi
    top = -1;
    return;
end

% Now that all corner cases are eliminated, an actual topology can be
% determined: an index array of all enclosed nodes.
if length(path)<100
    filter = 1;
else
    filter = 10;
end
probeA = path(1:filter:end,1);
probeB = path(1:filter:end,2);

if length(probeA) < 10
    for ind = 1:length(nodesA)
        locA = probeA - nodesA(ind);
        locA1 = probeA - nodesA(ind)+2*pi;
        locA2 = probeA - nodesA(ind)-2*pi;
        locB = probeB - nodesB(ind);
        locB1 = probeB - nodesB(ind)+2*pi;
        locB2 = probeB - nodesB(ind)-2*pi;
        if ~isempty(find(locA<0,1)) && ~isempty(find(locB<0,1)) && ...
           ~isempty(find(locA>0,1)) && ~isempty(find(locB>0,1))
            top(end+1) = ind;
        elseif ~isempty(find(locA1<0,1)) && ~isempty(find(locB<0,1)) && ...
               ~isempty(find(locA1>0,1)) && ~isempty(find(locB>0,1))
            top(end+1) = ind;
        elseif ~isempty(find(locA2<0,1)) && ~isempty(find(locB<0,1)) && ...
               ~isempty(find(locA2>0,1)) && ~isempty(find(locB>0,1))
            top(end+1) = ind;
        elseif ~isempty(find(locA<0,1)) && ~isempty(find(locB1<0,1)) && ...
               ~isempty(find(locA>0,1)) && ~isempty(find(locB1>0,1))
            top(end+1) = ind;
        elseif ~isempty(find(locA<0,1)) && ~isempty(find(locB2<0,1)) && ...
               ~isempty(find(locA>0,1)) && ~isempty(find(locB2>0,1))
            top(end+1) = ind;
        end
    end
else
    for ind = 1:length(nodesA)
        added = false;
        for mulA = (-2:1:2)
            for mulB = (-2:1:2)
                if InsideClosedCurve(probeA, probeB, ...
                                     nodesA(ind)+mulA*2*pi, ...
                                     nodesB(ind)+mulB*2*pi);
                    top(end+1) = ind;
                    added = true;
                    break
                end
            end %for
            if added
                break;
            end
        end %for
    end %for
end

% There is 1 case left: 
% It is possible for the path to turn around near discontinuities.
% In this case, an empty topology remains equivalent to an error.
end %CoverageTopology
