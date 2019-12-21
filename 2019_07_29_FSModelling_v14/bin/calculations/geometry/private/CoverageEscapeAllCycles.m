function sections = CoverageEscapeAllCycles(geometry, nodesA, nodesB, a, b, angle)
% Move along angle in (a,b) space until an orbit is found that wraps.
%
% OR: Use CoverageNextCycle repeatedly till topology=-1, saving each time.
% Note: Specificially meant for the case where (a,b) is a node itself.
%
% geometry : Geometry
% nodesA, nodesB : array of double
%    Together, these provide all the points where area=0 occurs.
% a,b : double
%   starting point to walk away from
% angle : double (radians)
%   direction in (a,b) space (!) to walk towards.
%
% sections : cell array of struct
%   .alpha
%       2-vector of starting point
%   .beta
%       2-vector of end point
%   .topology
%       the points enclosed by orbits over this path.
%       empty means this is undefined grounds.
%   
% Note: sections{1}.alpha is (a,b)
% Note: sections{end}.beta is the start of the topology=-1

sections = {};
newT = 0;
firstT = [];

while newT ~= -1
    [t,c,d,newT,g,h] = CoverageNextCycle(geometry, nodesA, nodesB, a, b, angle);
    sections(end+1:end+2) = {0};
    sections{end-1} = struct('alpha', [a,b], 'beta', [c,d], 'topology', t);
    sections{end}   = struct('alpha', [c,d], 'beta', [g,h], 'topology', []);
    a = g;
    b = h;
    
    if isempty(firstT)
        firstT = t;
    elseif isequal(newT, firstT)
        % This means we went full circle around the object without 
        % ever hitting a -1 region. The last limit cycle is considered
        % in this case to be the last one containing firstT.
        % In this case, cut off the end until you find one where 
        % all of firstT exists.
        for lastInd = length(sections):-1:1
            if IsPartOf(firstT, sections{lastInd}.topology)
                break;
            end
        end
        
        % Keep the filler that is assocated with the last one.
        sections = sections(1:lastInd+1);        
        break;
    end
end
end

function r = IsPartOf(sub, full)
% Check if all of sub exists in full.

for ind = 1:length(sub)
    found = false;
    for ind2 = 1:length(full)
        if sub(ind) == full(ind2)
            found = true;
            break;
        end
    end
    
    if ~found
        r = false;
        return;
    end
end
r = true;
end
