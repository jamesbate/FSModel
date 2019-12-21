function [x, y, value] = MarchingDescend2(func, x, y, dx, dy, isMini, ...
                                          epsX, epsY, epsval, meval)
% Find an extremum by a gradient descend in 2D. 
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
% epsX, epsY : double
%   Upper bound on the uncertainty of the extremum (absolute)
%   defaulted to 1/1e8 times dx/dy respectively.
%   Should be positive even if dx/dy are negative.
% epsval : double
%   Upper bound for the uncertainty
%   Defaulted to 1/1e8 times function value at (x, y)
% meval : int
%   Maximum number of function evaluations (default 1000)
%   if reached, an error is raised with id "Descend:max_evals"
%   Defaulted to 1000. It may overshoot a up to 4 evaluations.
% 
% Convergence criteria are OR, meaning 1 satisfied => stop.
%
% 16/6/2019 Roemer Hinlopen
% Note: This is straightforwardly generalizable to any dimension,
% but a minimum is used in first instance for what is necessary.

% Initiation
value = func(x, y);
evals = 1;

function r = isBetter(a, b)
    if isMini
        r = a < b;
    else
        r = a > b;
    end
end


% Defaults
if nargin < 6
    isMini = true;
end
if nargin < 7
    epsX = dx / 1e8;
end
if nargin < 8
    epsY = dy / 1e8;
end
if nargin < 9
    epsval = value / 1e8;
end
if nargin < 10
    meval = 1000;
end

% Actual 'gradient descend' in adjusted form
% The real clue is in the first line. The gradient is numerically
% evaluated, but the spacing of this approximatino depends on the scale
% currently used in the optimization procedure. This is my twist on it, it
% is just much more work to do it with linear backtracking and it is not
% per se as predictable or stable to adapt stepsizes to gradient sizes.
improve = epsval*2+1;
while true
    if evals > meval
        error('Descend:max_evals', ...
              'Maximum number of function evaluations reached %d.', evals);
    end
    zz = [func(x+dx/10, y), func(x, y+dy/10)];
    evals = evals + 2;
    
    % dz indicates the *direction* to go to, which is the direction of the
    % gradient for maxima, negative that for minima.
    % This is really only nan if you enter a function which is 100%
    % identical over the interval, which means it is always considered an
    % extremum. This is consistent, as a line of extremae is also found by
    % this algorithm at an arbitrary point along that line.
    dz = zz - value;
    dz = dz / norm(dz);
    if isnan(dz)
        break;
    end
    if isMini
        dz = -dz;
    end

    % The stepsize is fixed, the direction is determined by the gradient.
    xnew = x + dz(1) * dx;
    ynew = y + dz(2) * dy;
    new = func(xnew, ynew);
    evals = evals + 1;
    
    % These steps are continued to be taken until a local min/max is found
    % at which point either convergence is reached, or the stepsize is
    % reduced to get further detail.
    if isBetter(new, value)
        x = xnew;
        y = ynew;
        improve = abs(value - new);
        value = new;
        
    else
        % Check that this is an actual min/max diagonally.
        % Otherwise set a step to that point as a slow march.
        xx = [x-dx/sqrt(2), x+dx/sqrt(2), x+dx/sqrt(2), x-dx/sqrt(2)];
        yy = [y+dy/sqrt(2), y+dy/sqrt(2), y-dy/sqrt(2), y-dy/sqrt(2)];
        ztest = [func(xx(1), yy(1)), ...
                 func(xx(2), yy(2)), ...
                 func(xx(3), yy(3)), ...
                 func(xx(4), yy(4))];
        evals = evals + 4;
        
        if isMini && min(ztest) < value - abs(epsval)
            [v, index] = min(ztest);
            value = v;
            x = xx(index);
            y = yy(index);
        elseif ~isMini && max(ztest) > value + abs(epsval)
            [v, index] = max(ztest);
            value = v;
            x = xx(index);
            y = yy(index);

        % If it is proper, then consider convergence criteria.
        % Decrease the stepsize also when the above triggered,
        % else the problem will repeat itself and the above is 
        % always a strongly local issue anyways.
        elseif abs(dx) < epsX && abs(dy) < epsY
            break;
        elseif improve < epsval && max(ztest) - min(ztest) < epsval * 2
            break;    
        end
        dx = dx / 2;
        dy = dy / 2;
    end
end %for
end %MarchingExtremum
