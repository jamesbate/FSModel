function r = ExtremizeClassifyPoint(prev, now, next, maxi)
% Return 0 for max, 1 for min, 2 for discontinuity and NaN else.
%
% Responsibility: Defines the line between a steep hill and discontinuity.

% The 10% is a choice, but it seems like a good choice in practise.
% If such a discontinuity is present, either it has to be classified
% as linear and hence NaN, or a discontinuity and 2.
% It will never be seen as a min/max.
disc1 = abs(prev/now-1)>0.15 && abs(prev-now) > 0.1*maxi;
disc2 = abs(next/now-1)>0.15 && abs(next-now) > 0.1*maxi;
if disc1 || disc2    
    if (next-now) * (now-prev) <= 0
        r = 2;
    elseif abs(next-now) > abs(prev-now)*2 || abs(prev-now) > abs(next-now)*2
        r = 2;
    else
        r = NaN;
    end
    
% You do not want to find area=0 orbits.
elseif now < maxi/1000
    r = NaN;
    
% Maximum
elseif (prev <= now && next <= now)
    r = 0;

% Minimum (overwrite anyway for consistency)
elseif prev >= now && next >= now
    r = 1;

% Throw away
else
    r = NaN;
end
end %ExtremizeClassifyPoint
