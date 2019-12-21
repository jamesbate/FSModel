function sections = CoverageSections(geometry, nodesA, nodesB)

[endA, endB, nodesB, id] = CoverageEndpoints(geometry, nodesA, nodesB);
visited = CoveragePrimaryPath(geometry, nodesA, nodesB, id, endA, endB);
sections = CoverageCreatePath(geometry, nodesA, nodesB, visited);
sections = CoverageAddEndpoint(geometry, sections, nodesA, nodesB, endA, endB);
sections = CoverageVisitStandalone(geometry, nodesA, nodesB, sections);
sections = CoverageFilterDupeTopos(geometry, sections);

end %CoverageSections


function [endA, endB, nodesB, id] = CoverageEndpoints(geometry, nodesA, nodesB)
% Create a pair to walk between for primary path.
%
% There are 5 cases:
%   - the A axis is open => shift 2pi there
%   - the B axis is open => shift 2pi there
%   - shifting (2pi,0) maximal shift in distance => (2pi,0)
%   - shifting (0,2pi) maximal shift in distance => (0,2pi)
%   - shifting (2pi,2pi) maximal shift in distance => (2pi,2pi)

[x1,y1,z1] = geometry.Points(nodesA(1), nodesB(1));
[x2,y2,z2] = geometry.Points(nodesA(1)+2*pi, nodesB(1));
[x3,y3,z3] = geometry.Points(nodesA(1), nodesB(1)+2*pi);

if abs(x1-x2) > 0.01 * max(abs([x1,x2])) || ...
   abs(y1-y2) > 0.01 * max(abs([y1,y2])) || ...
   abs(z1-z2) > 0.01 * max(abs([z1,z2]))
    [~,id] = min(nodesA);
    endA = nodesA(id) + 2*pi;
    endB = nodesB(id);
    return;
    
elseif abs(x1-x3) > 0.01 * max(abs([x1,x3])) || ...
       abs(y1-y3) > 0.01 * max(abs([y1,y3])) || ...
       abs(z1-z3) > 0.01 * max(abs([z1,z3]))
    [~,id] = min(nodesB);
    endA = nodesA(id);
    endB = nodesB(id) + 2*pi;
    return;
    
else
    d1 = geometry.CalcDistance(nodesA(1), nodesB(1));
    d2 = geometry.CalcDistance(nodesA(1)+pi, nodesB(1));
    d3 = geometry.CalcDistance(nodesA(1), nodesB(1)+pi);
    d4 = geometry.CalcDistance(nodesA(1)+pi, nodesB(1)+pi);
    
    if abs(d1-d2) > abs(d1-d3) && abs(d1-d2) > abs(d1-d4)
        [~,id] = min(nodesA);
        endA = nodesA(id) + 2*pi;
        endB = nodesB(id);
        return;
        
    elseif abs(d1-d3) > abs(d1-d2) && abs(d1-d3) > abs(d1-d4)
        [~,id] = min(nodesB);
        endA = nodesA(id);
        endB = nodesB(id) + 2*pi;
        return;
        
    else
        [~,id] = min(nodesA);
        endA = nodesA(id) + 2*pi;
        endB = nodesB(id) + 2*pi;
        nodesB(nodesB < nodesB(id)) = nodesB(nodesB < nodesB(id)) + 2*pi;
        return;
    end
end
end %CoverageEndpoints


function visited = CoveragePrimaryPath(geometry, nodesA, nodesB, index, endA, endB)
% Make an array indicating the order in which you visit each node.
%
% Always starts at 'index' and ends at 'end', 
% visited matches nodes in length
% it contains 0's for not-visited points,
% 1,2,3,4,... indicates the actual path traversed.
%
% Draws a straight line between index and end,
% then considers all points and diverges to them if their limit 
% cycles are crossed.

visited = zeros(1,length(nodesA));
visited(index) = 1;

% Each iteration 1 new stop is found.
found = true;
while found
    nrSegments = max(visited);    
    found = false;
    for segment = 1:nrSegments
        
        % Find where this segment is located
        a1 = nodesA(find(visited==segment,1));
        b1 = nodesB(find(visited==segment,1));
        if segment < nrSegments
            a2 = nodesA(find(visited==segment+1,1));
            b2 = nodesB(find(visited==segment+1,1));
        else
            a2 = endA;
            b2 = endB;
        end
        
        % Then find if there is a node whose limit cycle intersects
        % this line.
        for ind=1:length(nodesA)
            if visited(ind) > 0
                continue;
            end

            close = ClosestApproach([nodesA(ind),nodesB(ind)], ...
                                    [a1,b1],[a2,b2]);

            if ~isnan(close(1))
                top = CoverageTopology(geometry, close(1),close(2), ...
                                       nodesA, nodesB);
                if ismember(ind, top)                
                    visited(visited>segment) = visited(visited>segment) + 1;
                    visited(ind) = segment+1;
                    found = true;
                    break
                end
            end
        end 
        
        % If it was found, nrSegments has to be reset.
        if found
            break;
        end
    end
end
end %CoveragePrimaryPath


function sections = CoverageCreatePath(geometry, nodesA, nodesB, visited)
% Create a path going through the nodes as outlined in visited.
% Visited is an array with zeros (not visited) and unique 
% 1,2,3,4,... which outline a trace to pass through.
%
% Assumes this path will not make inter-cycle connections pass through
% another cycle.

nrSegments = max(visited) - 1;

% Trivial case 
if nrSegments == 0
    id = find(visited==1,1);
    sections = CoverageEscapeAllCycles(geometry,nodesA,nodesB,...
                                       nodesA(id),nodesB(id),0);
     return;
end

sections = {};
for ind = 1:nrSegments
    start = find(visited==ind);
    towards = find(visited==ind+1);
    s = MakeConnection(geometry, nodesA, nodesB, start, towards, ind==nrSegments);
    sections(end+1:end+length(s)) = s;    
end

end %CoverageCreatePath


function sections = CoverageAddEndpoint(geometry, sections, nodesA, nodesB, endA, endB)
% Do 1 of 2 things:
%   - endA/endB is the alpha of the last section, meaning this node
%       is already visited and this function does nothing.
%   - Otherwise, make a connection between the last node and the endA/endB
%       node.


% When the endpoint is degenerate with another
% e.g. (2pi,0) and (2pi,pi) on a sphere
% Then there is nothing more to add.
s = sections{end};
[x,y,z] = geometry.Points(s.beta(1),s.beta(2));
[x2,y2,z2] = geometry.Points(endA, endB);
if x==x2 && y==y2 && z==z2
    return;
end

% Otherwise, go from the last section => end
% But only take the intermediate region, the starting cycle
% is already assumed there and the end cycle is assumed identical
% to the first. If it is not (e.g. Sphere) then that end pole
% also exists and the above catches that case.
norm = sqrt((s.beta(1)-endA)^2 + (s.beta(2)-endB)^2);
angle = acos((endA-s.beta(1)) / norm);
if endB < s.beta(2)
    angle = -angle;
end

% This happens in objects without -1 region,
% think Torus or Sphere.
if ~isempty(s.topology)
    s1 = CoverageEscapeAllCycles(geometry,nodesA, nodesB, ...
                                 s.beta(1),s.beta(2),angle);
else
    s1 = sections(end);
end

nodesA2 = [nodesA, endA];
nodesB2 = [nodesB, endB];
s2 = CoverageEscapeAllCycles(geometry,nodesA2,nodesB2,...
                             endA,endB,pi+angle);

sections{end+1} = struct('alpha', s1{end}.beta, ...
                         'beta', s2{end}.beta, ...
                         'topology', -1);
                     
end %CoverageAddEndpoint


function sections = CoverageVisitStandalone(geometry, nodesA, nodesB, sections)

% Find out which are already done
visited = zeros(1,length(nodesA))==1;
for ind = 1:length(sections)
    t = sections{ind}.topology;
    if length(t)~=1 || t(1) <= 0
        continue;
    end
    visited(t) = true;
end

% Cover the rest
for ind = 1:length(visited)
    if visited(ind)
        continue;
    end
    s = CoverageEscapeAllCycles(geometry, nodesA, nodesB, nodesA(ind), nodesB(ind), pi/4);
    sections(end+1:end+length(s)) = s;
end


end %CoverageVisitStandalone


function sections = CoverageFilterDupeTopos(geometry, sections)
% Remove sections with the same topology.
%
% This specifically happens for 2-topology (or more) regions.
% Singles are generally already covered exactly once.

keep = ones(1,length(sections)) == 1;
for ind = 1:length(sections)
    s1 = sections{ind};
    d1 = geometry.CalcDistance(s1.alpha(1), s1.alpha(2));
    d2 = geometry.CalcDistance(s1.beta(1), s1.beta(2));
    if isempty(s1.topology) || s1.topology(1) < 0
        continue;
    end
    
    % Find regions with the same topology.
    for ind2 = 1:ind-1
        s2 = sections{ind2};
        if isequal(s1.topology, s2.topology)
            d3 = geometry.CalcDistance(s2.alpha(1), s2.alpha(2));
            d4 = geometry.CalcDistance(s2.beta(1), s2.beta(2));
            if abs(d3-d4) < abs(d1-d2)
                destroy = ind2;
            else
                destroy = ind;
            end
            
            % 1) don't care to overwrite an already false again.
            % 2) keep the one with largest distance coverage.
            %       This should guarantee as much as possible is covered.
            % 3) Also destroy the connection piece to the next region if
            %       it exists for this region.
            keep(destroy) = false;
            if destroy < length(sections) && ...
               isempty(sections{destroy+1}.topology)
                keep(destroy+1) = false;
            end     
        end
    end %for
end %for
sections = sections(keep);
end %CoverageFilterDupeTopos


function sections = MakeConnection(geometry, nodesA, nodesB, id1, id2, full)
% Create all sections to get from one node to the next.
% If full: add 1+intermediate+2
% Otherwise: add 1+intermediate

if nodesA(id1)==nodesA(id2) && nodesB(id1)==nodesB(id2)
    sections = {struct('alpha', [nodesA(id1),nodesB(id1)], ...
                       'beta', [nodesA(id2),nodesB(id2)], ...
                       'topology', [id1,id2])};
    return;
end

% First derive how to go id1 => id2
norm = sqrt((nodesA(id1)-nodesA(id2))^2 + ...
            (nodesB(id1)-nodesB(id2))^2);
angle = acos((nodesA(id2)-nodesA(id1)) / norm);
if nodesB(id2) < nodesB(id1)
    angle = -angle;
end

% Move out of both cycles
s1 = CoverageEscapeAllCycles(geometry,nodesA,nodesB,...
                             nodesA(id1),nodesB(id1),angle);
s2 = CoverageEscapeAllCycles(geometry,nodesA,nodesB,...
                             nodesA(id2),nodesB(id2),pi+angle);

% Make only the initial cycle and *blindly* the intermittent region.
% i.e. at this point assume that there is no cycle interrupting this line.
% 
% The line goes 1 => 2.
sections = s1;
sections{end+1} = struct('alpha', s1{end}.beta, 'beta', s2{end}.beta, ...
                         'topology', -1);    
                     
if full
    sections(end+1:end+length(s2)) = {0};
    
    for ind = 1:length(s2)
        sections{end-ind+1} = struct('alpha', s2{ind}.beta, ...
                                     'beta', s2{ind}.alpha, ...
                                     'topology', s2{ind}.topology);
    end
    
else
    sections{end+1} = struct('alpha', s2{end}.beta, 'beta', s2{end}.alpha, ...
                             'topology', []);
end
end %MakeConnection


function r3 = ClosestApproach(r, r1, r2)
% Given a line segment (x1,y1) to (x2,y2), return the projection 
% of (x,y) on that line or NaN if the projection falls outside the segment.

distance = norm(r2-r1);
direc = (r2-r1) / distance;
connect = r-r1;
term = dot(direc, connect);
if term < -0.0001 || term > distance*1.0001
    r3 = [NaN,NaN];
    return;
end

r3 = r1 + term .* direc;
end %ClosestApproach
