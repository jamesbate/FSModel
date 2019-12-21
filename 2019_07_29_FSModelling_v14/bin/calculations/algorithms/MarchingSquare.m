function path = MarchingSquare(func, x, y, dx, dy, maxiter, finish, mods)
% Follow func(x,y)=constant in 2D with given stepsize.
% Returns the full path, e.g. path(1000, 2) in size.
%
% Input
% -----
% func : function of 2 arguments x, y
% x, y : number, starting point
% dx, dy : number, stepsize
% maxiter (optional, 10000) : int, number of iterations
%    Function is evaluated once with 2 doubles, 
%    and up to maxiter-1 times with 4-vectors
%    so you can also use it as a max function eval boundary
% finish (optional, true) : bool
%   if set, raise an error if the starting point is not reached again.
%   In any case, the algorithm stops after 1 period exactly.
% mods (optional, [0, 0]) : 2-vector
%   If given, x and y are considered periodic in this quantity
%   read: radians are periodic 2pi and without this the periodicity
%   cannot be found
% 
% Output
% ------
% Moves around in steps of about magnitude about (dx/2, dy/2) 
% until a return is found. Return the path as [(x,y), (x,y), ...].
% In other words path(1000, 2) is an example size.
%
% Algorithm
% ---------
% The algorithm is a changed marching squares.
% The idea is to evaluate the function over 4 points shifted by
% northwest, northeast, southeast, southwest wrt the current position.
% Then find the 2 sides where func()=value is crossed.
% Then linearly interpolate this side for its crossing point.
% Those are the two potential futures.
% The one chosen is the one furthest away from the last point,
% measured in units of dx/dy not in absolute units.
%
% Tip: If you want to evaluate a function over this path,
% evaluate this twice with half the stepsize the second time
% to estimate the error.
% NB: the path does NOT include the z coordinate, just xy
% This is because the algorithm does not need to know the value 
% right now, only of the 4 corners around you to determine your goal.
% To do 25% extra computations is not proper.
%

% 28 May 2019: First version of MarchingSquares
% 28 May 2019: New version. From square position to point position.
% 04 June 2019: Fix a bug on the east border
% 04 June 2019: New version. Use point memory instead of direction memory
%               the issue was that reversal occured for large steps.
% 14 June 2019: Cut into multiple files and adjust documentation.
%

% Initialize defaults
if nargin < 6
    maxiter = 10000;
end
if nargin < 7
    finish = true;
end
if nargin < 8
    mods = [1e99, 1e99];
elseif mods(1) <= 0
    mods(1) = 1e99;
elseif mods(2) <= 0
    mods(2) = 1e99;
end

% Initialize variables
x0 = x;
y0 = y;
z0 = func(x0, y0);
path = [];
path(1, :) = [x, y];
xold = x;
yold = y;

% Start running
% xx/yy/zz are northwest, northeast, southeast, southwest.
for ind = 1:maxiter
    % 1) Evaluate in a square around this point (considered limiting)
    xx = [x - dx/2, x + dx/2, x + dx/2, x - dx/2];
    yy = [y + dy/2, y + dy/2, y - dy/2, y - dy/2];
    zz = func(xx, yy);

    % 2) Find the correct position to move towards
    [xnew, ynew] = MarchingNext(zz, z0, x, y, dx, dy, xold, yold, ind-1);

    xold = x;
    yold = y;
    x = xnew;
    y = ynew;
        
    % 3) Process the result
    path(ind + 1, :) = [x, y];

    % 4) Check if we are back at the starting point yet.
    x_returned = abs(x - x0) < dx || abs(mods(1) - abs(x - x0)) < dx;
    y_returned = abs(y - y0) < dy || abs(mods(2) - abs(y - y0)) < dy;
    if ind > 2 && x_returned && y_returned
        path = path(1:ind + 1, :);
        break;
    end
end %for

if nargin >= 7 && finish && ind >= maxiter
    error('%s%d%s%s', 'Path did not finish after ', ind, ...
          ' steps. Either stepsize is very small, ',...
          'or you tunneled between almost touching orbits.');
end
end %MarchingSquare


