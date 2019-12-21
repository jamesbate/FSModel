function result = ExtremizeRefine(geometry, aa3, bb3, areas3, isMini)
% Do a local descend to find a precise version of this extremum
% before turning it into a result struct.
%
% aa3, bb3: coordinates around the extremum
% areas3: corresponding areas
% isMini: true/false
%
% The result struct contains:
%   .a & .b        => A position on the orbit
%   .plane         => The distance of the orbit along direction to origin.
%   .area, .dArea  => The extremal area enclosed
%   .converged     => If set, precision otherwise optimizer limited
%   .isMini        => min/max
%
% Returns NaN if this runs head first into a discontinuity.

function res = AreaFromDistance(distance)
    [A, B] = geometry.FindPlane(distance, aa3(2), bb3(2));
    res = geometry.CalcArea(A, B);
end


dist0 = geometry.CalcDistance(aa3(2), bb3(2));
distL = geometry.CalcDistance(aa3(1), bb3(1));
distR = geometry.CalcDistance(aa3(3), bb3(3));
dDist = max(abs(dist0-distL), abs(distR-dist0));
[area0, dArea0] = geometry.CalcArea(aa3(2), bb3(2));

try
    [distance, ~] = WalkingDescend1(@AreaFromDistance, dist0, ...
                                    dDist/2, isMini, 1e-10*area0, dArea0/10, ...
                                    dist0-dDist, dist0+dDist, false, ...
                                    100, true);
    [a, b] = geometry.FindPlane(distance, aa3(2), bb3(2));
    [area, dArea] = geometry.CalcArea(a, b);
    
    yLow = AreaFromDistance(distance - dDist/5);
    yUp = AreaFromDistance(distance + dDist/5);
    if abs(yUp-area)>0.1*area || abs(yLow-area)>0.1*area
            error('Refine:Discontinuity', 'This is not an extremum, it is a discontinuity.');
    end
    curvature = ParabolaCurvature(distance, dDist/5, yLow, area, yUp);
    converged = true;
catch exc 
    
    if strcmp(exc.identifier, 'Refine:Discontinuity')
        result = NaN;
        return;
    end
    
    % Possibly interesting if you think this misbehaved somehow:
    %dd = linspace(dist0-dDist, dist0+dDist, 30);
    %aa = zeros(1, length(dd));
    %for ind = 1:length(aa)
    %    aa(ind) = AreaFromDistance(dd(ind));
    %end
    %figure;
    %plot(dd, aa);
    %title(isMini);
    %figure;
    
    % These are zero-sized orbits or otherwise terrible things that 
    % are not considered worth reporting, rather it is a service to
    % catch them off and silence them.
    if dArea0 == 0 || dArea0 > area
        result = NaN;
        return;
    end
    
    a = aa3(2);
    b = bb3(2);
    area = areas3(2);
    dArea = max([dArea0, abs(areas3(1)-areas3(2)), abs(areas3(3)-areas3(2))]);
    distance = dist0;
    converged = false;
    curvature = ParabolaCurvatureIrr(distL, dist0, distR, ...
                                     areas3(1), areas3(2), areas3(3));
    fprintf('Failed to refine an orbit at distance %.3e, area %.3e: %s\n', ...
            dist0, areas3(2), exc.message);
end
result = struct('a', a, 'b', b, 'area', area, 'dArea', dArea, ...
                'plane', distance, 'isMini', isMini, ...
                'curvature', curvature, 'converged', converged);
end %ExtremizeRefine
