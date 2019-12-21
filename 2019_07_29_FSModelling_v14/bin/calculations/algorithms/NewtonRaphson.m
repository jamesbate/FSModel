function position = NewtonRaphson(func, value, x0, delta, dx, dy, miters)
% Find *a* point func=value using Newton-Ralphson with numerical derivative
%
% func: function ["x0 like"] => R
%   x0 may be an array of arbitrary length
% x0 : array of double
%   Starting point
%
% delta (optional): double
%   Stepsize along each dimension
%   Defaulted to max(x0)/10000, minimum 1e-7.
% dx (optional): double
%   Absolute uncertainty to reach in each dimension
%   Defaulted to delta * 10
% dy (optional): double
%   Absolute uncertainty to reach
%   Defaulted to delta * 10
% miters (optional): int
%   Maximum number of iterations to run.
%   Number of function evaluations is approximately (lenght(x0)+1)*miters
%   Defaulted to 100
%

% Defaults
if nargin < 4
    delta = max(abs(x0)) * 1e-4 + 1e-7;
end
if nargin < 5
    dx = delta*10;
end
if nargin < 6
    dy = value * 1e-8;
end
if nargin < 7
    miters = 100;
end

% Initiate
% offset is used to shift the position for gradient calculations.
% convergedCount is used to check that multiple subsequent iterations have
% converged, which should guarantee the error.
position = x0;
current = func(position);
dimension = length(x0);
grad = zeros(1, dimension);
offset = zeros(1, dimension);
convergedCount = 0;
reducedStep = 1;

vv = [];

% Iterate
for iter = 1:miters
    
    % Calculate the gradient
    for ind = 1:dimension
        if ind==1 
            last=dimension; 
        else 
            last=ind-1;
        end
        offset(last) = 0;
        offset(ind) = 1;
        grad(ind) = (func(position+delta*offset) - func(position)) / delta;
    end %for
    
    % NewtonRalphson iterative step.
    % The math is a linear taylor approximation
    %   f(x) = f(x0) + f'(x0) * dx = value
    %   x1 = x0 + dx = x0 - (f(x0)-value)/f'(x0)
    % Multidimensionally the f' turns into a gradient and
    % dx is in the direction of grad, but still divide by |grad|
    grSize = norm(grad);    
    grUnit = grad / grSize;
    nextPos = position - (current - value) .* grUnit / grSize / reducedStep;
    newval = func(nextPos);
    
    % Convergence criteria.
    converged = true;
    for ind2 = 1:dimension
        if abs(nextPos(ind2) - position(ind2)) > dx
            converged = false;
        end
    end %for
    if converged || abs(newval - value) < dy
        convergedCount = convergedCount + 1;
    else
        convergedCount = 0;
    end
    if convergedCount > 1
        break;
    end
    
    % This reduction of stepsize can help very well
    % The reasoning is that in divergent scenario's, mostly the gradient is
    % still in the right direction but overshoots the value further and
    % further. So reduce the step size to see if that helps. Until it does
    % not and then just call it a day.
    if abs(current - value) < abs(newval - value)
        reducedStep = reducedStep * 2;
    else
        if reducedStep > 10
            error('NR:Divergence', 'No convergence was possible.');
        elseif reducedStep > 1
            reducedStep = reducedStep - 0.5;
        end
        position = nextPos;
        current = newval;
    end
end %while


for ind = 1:length(position)
    if isnan(position(ind))
        error('NewtonRaphson ended in NaN');
    end
end %for
if iter >= miters
    error('No convergence after %d Newton-Ralphson steps. Final position (%.3e, %.3e)',...
          iter, position(1), position(2));
end
end %NewtonRalphson
