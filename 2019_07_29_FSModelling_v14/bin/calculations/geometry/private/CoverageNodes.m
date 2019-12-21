function [aa, bb] = CoverageNodes(geometry)
% Find 0-area orbits by using the identity that they are at those places
% where the distance is maximized or minimized. 
%
% 2-stage process: 
%   1) Make a whole bunch of probes and select rough min/max there
%   2) Use walking descend to refine them fully.


% Note: refine is limiting by a factor 5 in time from experimentation
% with a corrugated cylinder. However in general this method is 
% very quick (~0.1 seconds) so I do not truly care.
%
% The points filter kicks out duplicates in AB/XYZ space, 
% and validity kicks out points that just fail, but are area~=0 points.
%
% The first can happen generally when multiple probes seem different 
% but converge to the same endpoint, it is conceivable. The last is
% necessary in the case you use a sphere at non-0 polar degrees, 
% the pole will be seen as a failing orbit but it is not zero area.
% Finally, XYZ filter is in the same situation but when it is exactly
% the case that you measure along the pole direction (which people tend
% to do sadly) and you have to kick out the 50+ duplicates which differ
% in phi but all have theta=0, by realizing that they are the same in xyz
% space.
amount = 69;
[aa0, bb0, isMinis] = NodalPointsProbes(geometry, amount);
[aa1, bb1] = NodalPointsRefine(geometry, aa0, bb0, isMinis, pi/amount);
[aa2, bb2] = NodalPointsFilterAB(aa1, bb1);
[aa3, bb3] = NodalPointsFilterXYZ(geometry, aa2, bb2);
[aa, bb] = NodalValidityFilter(geometry, aa3, bb3);
end %CoverageNodes


function [aa, bb, isMinis] = NodalPointsProbes(geometry, amount)
% Make a mesh of points in [a,b] space.
% Calculate their distances
% Filter out the extremal distance locations
% Return these rough extremae.
%
% Recommended: amount >10 and an odd number to have no worries.

nrA = amount;
nrB = amount;
startA2 = (-0.1:2*pi/(nrA-1):2*pi+0.1);
startB2 = (-0.1:2*pi/(nrB-1):2*pi+0.1);
[AA, BB] = meshgrid(startA2, startB2);
DD = geometry.CalcDistance(AA, BB);

% For visualization. The most important aspect is that the entire 
% surface is very smooth and nicely behaving.
%figure;
%surf(AA, BB, DD);

aa = zeros(1, 150);
bb = zeros(1, 150);
isMinis = zeros(1, 150);
lastIndex = 0;
for ind1 = 2:length(startA2)-1
    last1 = ind1-1;
    next1 = ind1+1;
    for ind2 = 2:length(startB2)-1
        last2 = ind2-1;
        next2 = ind2+1;
        surround = [DD(last2, last1), DD(last2, next1), ...
                    DD(next2, last1), DD(next2, next1)];
        if DD(ind2, ind1) > max(surround) || DD(ind2, ind1) < min(surround)
            lastIndex = lastIndex + 1;
            aa(lastIndex) = startA2(ind1);
            bb(lastIndex) = startB2(ind2);
            isMinis(lastIndex) = DD(ind2, ind1) < min(surround);
        end
    end %for
end %for
aa = aa(1:lastIndex);
bb = bb(1:lastIndex);
isMinis = isMinis(1:lastIndex);

if length(aa) > 100
    aa = [];
    bb = [];
    isMinis = [];
end

end %LocateNodesProbes


function [aa, bb] = NodalPointsRefine(geometry, aa, bb, isMinis, delta)
% Use walking descend to find more precise extremae. 
% Delta is the initial stepsize / about the max uncertainty you have.

% The accuracy to be reached in [a,b] has to be given as a factor compared
% to the initial stepsize, aim at a precision of 1e-8.
improve = delta / 1e-8;
for ind = 1:length(aa)
    try
        [aa(ind), bb(ind)] = WalkingDescend2(@geometry.CalcDistance,...
                                             aa(ind), ...
                                             bb(ind),... %starting point
                                             delta, ...
                                             delta, ... %starting shift
                                             isMinis(ind), ...
                                             improve, ... %factor shift reduce
                                             aa(ind)-10*delta, ...
                                             aa(ind)+10*delta, ...
                                             bb(ind)-10*delta, ...
                                             bb(ind)+10*delta, ... %limits on a/b
                                             2, ... %limit means error.
                                             1000); %max func evals
    catch exc
        % Open ends of a non-corrugated cilinder are discarded by running 
        % away, which is not very cheap but works.
        aa(ind) = NaN;
        bb(ind) = NaN;
        if isempty(strfind(exc.message, 'optimization interval'))
             rethrow(exc);
        end
    end %try
end %for

% In case we left the interval somewhere, map back to the primary zone.
% It is not possible to use the boundary conditions of WalkingDescend,
% because CalcDistance is not periodic when e.g. the end of a cilinder 
% axis is reached. Whatever you extract is equivalent however between
% subsequent zones, so map back to the central zone.
aa(isnan(aa)) = [];
bb(isnan(bb)) = [];
aa = mod(aa, 2*pi);
bb = mod(bb, 2*pi);
end %LocateNodesRefine.


function [aa, bb] = NodalPointsFilterXYZ(geometry, aa, bb)
% If you measure e.g. a sphere with polar=0, then you get
% a ton of values with theta=0 and various phi, because you 
% lost injectivity in this point. This maps everything to xyz and then 
% checks which are equivalent and keeps only one copy.

% Doing it up front at once >>>>> doing it repeatedly in single calls.
[X, Y, Z] = geometry.Points(aa, bb);
keep = ones(1,length(aa))==1;
for ind = 1:length(aa)
    R = sqrt(X(ind)^2+Y(ind)^2+Z(ind)^2);
    for ind2 = 1:ind-1
        if abs(X(ind)-X(ind2))/R < 1e-10 && ...
           abs(Y(ind)-Y(ind2))/R < 1e-10 && ...
           abs(Z(ind)-Z(ind2))/R < 1e-10
            keep(ind) = false;
        end
    end
end
aa = aa(keep);
bb = bb(keep);

if length(aa) == 1
    aa = [];
    bb = [];
end

end %NodalPointsFilterXYZ

function [aa2, bb2] = NodalPointsFilterAB(aa, bb)
% Kick out duplicates, defined as points that differ less than 0.01 in 
% both coordinates at the same time.

aa2 = zeros(1, length(aa));
bb2 = zeros(1, length(aa));
lastIndex = 0;
for ind = 1:length(aa)
    
    % Check if (aa(ind),bb(ind)) already exists among the 
    % second version aa2, bb2.
    %
    % The difference of 0.01 is really safe. 
    % The walking descend accuracy is orders of magnitude lower,
    % any shape where there are two actually closer than that
    % is both unthinkable in reality and they won't be picked up 
    % anyways as you would need amount to exceed 1000 to find them.
    found = false;
    for ind2 = 1:lastIndex
        sameA = false;
        dA = abs(aa(ind) - aa2(ind2));
        if dA < 0.01
            sameA = true;
        elseif abs(dA - 2*pi) < 0.01
            sameA = true;
        end

        sameB = false;
        dB = abs(bb(ind) - bb2(ind2)); 
        if dB < 0.01
            sameB = true;
        elseif abs(dB - 2*pi) < 0.01
            sameB = true;
        end      
        
        if sameA && sameB
            found = true;
            break;
        end
    end

    if ~found
        lastIndex = lastIndex + 1;
        aa2(lastIndex) = aa(ind);
        bb2(lastIndex) = bb(ind);
    end
end

aa2 = aa2(1:lastIndex);
bb2 = bb2(1:lastIndex);
end %LocateNodesFilter


function [aa, bb] = NodalValidityFilter(geometry, aa, bb)
% Remove nodes which are really parametrization poles.
% Think: the poles on a sphere with spherical coordinates

% Normal ones are quick to return area=0 here.
keep = ones(1, length(aa))==1;
for ind = 1:length(aa)
    try
        geometry.CalcArea(aa(ind), bb(ind));
    catch
        keep(ind) = false;
    end
end
aa = aa(keep);
bb = bb(keep);
end %NodalValidityFilter