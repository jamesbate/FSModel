function [x, y, value] = WalkingDescend2(func, x, y, dx, dy, isMini, acc, ...
                                        minx, maxx, miny, maxy, isMod, ...
                                        meval)
% Find an extremum by a walking around in 2D. 
% NOTE: use MarchingDescend if your function has no discontuity/boundary
%       issues, use this if you want absolute robustness and stability.
%
% func : function [R, R] : R
%   2D Function to extremize
%   Only called with single values, not arrays.
% x, y : double
%   starting point
% dx, dy : double
%   Stepsize in x and y to take.
%   The ratio of the stepsize is preserved during the search.
%   Steps are purely in x or purely in y direction.
%   Negative is not a problem.
%
% isMini (optional) : bool
%   If set, search for a minimum (default) else maximum
% acc (optional) : double
%   How many times smaller does (dx,dy) have to get for convergence.
%   Default 1024
%   Will boil down to the first power of 2 above your value.
% minx, miny, maxx, maxy (optional): double
%   Interval limits for the search.
%   Defaulted to 1e99 and -1e99.
%   If isMod is set, minima are forced to 0.
% isMod : bool
%   If set, the limits are periodic bounds
%   If unset (default), the limits are hard bounds.
% meval : int
%   Maximum number of function evaluations (default 1000)
%   if reached, an error is raised with id "Descend:max_evals"
%   Defaulted to 1000. It may overshoot a up to 4 evaluations.
% 
% Convergence criteria are OR, meaning 1 satisfied => stop.
%
% 18/6/2019 Roemer Hinlopen
% Note: This is straightforwardly generalizable to any dimension,
% but a minimum is used in first instance for what is necessary.

% Initiation
x0 = x;
y0 = y;
value = func(x, y);
evals = 1;

function location = findBetterThan(a, b)
    % Check if any of A is an improvement over B.
    % If not, return 0
    % Else, return the index of largest improvement.
    improvement = 0;
    location = 0;
    for ind = 1:length(a)
        deltaA = max(a(:)) - min(a(:));
        
        % This check is an empirical addition.
        % Sometimes 1 dimension does not change the result except for
        % numerical stability. Then that stepsize at some point is reduced
        % to a very small number, only to then due to numerical precision
        % shift the minimum to the other side of the universe, resulting in
        % expensive or even no convergence.
        if deltaA~=0 && abs(a(ind)-b)/deltaA < 1e-10
            continue;
        end
        
        if isMini
            if a(ind) < b - improvement
                improvement = b - a(ind);
                location = ind;
            end
        else
            if a(ind) > b + improvement
            	improvement = a(ind) - b;
                location = ind;
            end
        end
    end %for
end %findBetterThan


% Defaults
if nargin < 6
    isMini = true;
end
if nargin < 7
    acc = 1000;
end
if nargin < 8
    minx = -1e99;
end
if nargin < 9
    maxx = 1e99;
end
if nargin < 10
    miny = -1e99;
end
if nargin < 11
    maxy = 1e99;
end
if nargin < 12
    isMod = false;
end
if nargin < 13
    meval = 1000;
end
if isMod == 1
    minx = 0;
    miny = 0;
end
accuracy = dx / acc;

% Actual code
% Each iteration, evaluate in a square around the central point. 
% Then choose the best option out of these.
% 
% This is strictly worse than gradient descend without more options.
% It allows for a trick though: The points can be prevented from shifting
% over the boundary really naturally and hence boundary problems are
% actually the good case instead of a very hard case.
chain = 0;
while true
    if evals > meval
        error('Descend:max_evals', ...
              'Maximum function evaluations reached %d, start (%.3e, %.3e).',...
              evals, x0, y0);
    end
    
    [xnew, ynew] = NextPositions2(x, y, dx, dy, minx, maxx, miny, maxy, isMod);
    try
        new = [func(xnew(1), ynew(1)), func(xnew(2), ynew(2)), ...
               func(xnew(3), ynew(3)), func(xnew(4), ynew(4))] ;
        evals = evals + 4;
    catch exc
         rethrow(exc);
    end
        
    index = findBetterThan(new, value);
    if index == 0
        if dx < accuracy
            break;
        else
            chain = 0;
            dx = dx/2;
            dy = dy/2;
        end
    else
        chain = chain + 1;
        x = xnew(index);
        y = ynew(index);
        value = new(index);
        
        if chain > 3
            dy = dy*2;
            dx = dx*2;
            chain = 0;
        end            
    end
end %for
end %WalkingExtremum


function [xx, yy] = NextPositions2(x, y, dx, dy, minx, maxx, miny, maxy, isMod)
% Shift to north/..., but respect the limits of the interval.

function value = adjust(value, low, high, isMod)
    % If isMod is set, low is ignored.
    % This is where the boundary behaviour is implemented.
    % If a step passes the bound, set it to the bound.
    % Unless modulo is set, in which case it is mapped back with mod.
    if value < low
        if isMod==1
            value = mod(value, high);
        elseif isMod==2
            error('Lower optimization interval breached %.3e', low);
        else
            value = low;
        end
    elseif value > high
        if isMod==1
            value = mod(value, high);
        elseif isMod==2
            error('Upper optimization interval breached %.3e', high);
        else
            value = high;
        end
    end
end %adjust

xx = [x-dx/2, x+dx/2, x, x];
yy = [y, y, y-dy/2, y+dy/2];
for ind = 1:length(xx)
    xx(ind) = adjust(xx(ind), minx, maxx, isMod);
    yy(ind) = adjust(yy(ind), miny, maxy, isMod);
end %for
end %NextPositions2
