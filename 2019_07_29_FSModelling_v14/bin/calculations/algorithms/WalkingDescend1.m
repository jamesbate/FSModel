function [x, value, dx, valErr] = WalkingDescend1(func, x, dx, isMini, accX, accY, ...
                                      minx, maxx, isMod, meval, errorStop)
% Find an extremum by a walking around in 1D. 
% NOTE: use this if you want absolute robustness and stability.
% NOTE: In general these kinds of algorithms are fine in low D.
%
% func : function R : R
%   1D Function to extremize
%   Only called with single values, not arrays.
% x : double
%   starting point
% dx : double
%   Stepsize in x.
%
% isMini (optional) : bool
%   If set, search for a minimum (default) else maximum
% accX (optional) : double
%   How small dx have to get for convergence.
%   Default dx/1024
%   Intervals decrease in powers of 2.
% accY (optional) : double
%   How much may the observed variation of the function value be
%   Default 1e-99. 
% minx, maxx (optional): double
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
% errorStop : bool
%   If an error occurs in the function, consider that convergence.
%   Defaulted to false.
% 
% Convergence criteria are OR, meaning 1 satisfied => stop.
%
% 19/6/2019 Roemer Hinlopen
% Note: This is possible to generalize to any D but really not necessary
% at this time and I do not want to have the burden of testing that 
% rigorously only to find some instability.

% Initiation
value = func(x);
evals = 1;
valErr = value;

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
if nargin < 4
    isMini = true;
end
if nargin < 5
    accX = dx / 1000;
end
if nargin < 6
    accY = 1e-99;
end
if nargin < 7
    minx = -1e99;
end
if nargin < 8
    maxx = 1e99;
end
if nargin < 9
    isMod = false;
end
if nargin < 10
    meval = 1000;
end
if nargin < 11
    errorStop = false;
end
if isMod
    minx = 0;
end
noStepsTaken = true;

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
              'Maximum function evaluations reached %d at %.3e.',...
              evals, x);
    end
    
    xnew = DescendNext1(x, dx, minx, maxx, isMod);
    try
        new = [func(xnew(1)), func(xnew(2))] ;
    catch exc
        if errorStop
            break;
        else
            rethrow(exc);
        end
    end %try
    evals = evals + 2;
    index = findBetterThan(new, value);
    
    % If nothing is better, either decrease stepsize for further precision
    % or call it a day.
    if index == 0
        if 2 * max(abs(new - value)) < accY || dx < accX
            break;
        else
            chain = 0;
            if noStepsTaken
                dx = dx/10;
            else
                dx = dx/2;
            end
        end
        
    % Else you take this value and go on. 
    % Note that by cutting dx in half each iteration, any new best position
    % should be reached in 2 steps, so chain should only come into play 
    % in the early iterations.
    else
        chain = chain + 1;
        x = xnew(index);
        value = new(index);
        noStepsTaken = false;
        
        if chain > 4
            dx = dx*2;
            chain = 0;
        end            
    end
end %for

% You can enable this to see how it performs.
%fprintf('In %d evaluations to %.3e +- %.3e in y (required %.3e)\n', ...
%        evals, value, max(abs(new-value)), accY);
end %WalkingDescend1

