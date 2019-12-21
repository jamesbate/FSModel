function [xn, yn] = MarchingNext(zz, z0, x, y, dx, dy, xold, yold, stepnr)
% Find the position to move to next.
%
% zz : 4-vector
%   The function values northwest and then clockwise around [x,y] with 
%   stepsizes [dx/2,dy/2] 
% z0 : double
%   The value of z (function) to follow
% x, y : double
%   The current position
% dx, dy : double
%   the stepsize used to determine zz
% xold, yold : double
%   The previous position (necessary to move away and not return)
% stepnr : int
%   Displayed sometimes if errors occur.
%   It says something if this crashed after 0 or 1000 steps into 
%   an extremum or end point.
%
% Responsibility: Query possible futures, select the furthest from old
%

[xopt, yopt] = MarchingInterpolate(zz, z0, x, y, dx, dy, stepnr);

distSquared1 = dy^2*(xopt(1) - xold)^2 + dx^2*(yopt(1)-yold)^2;
distSquared2 = dy^2*(xopt(2) - xold)^2 + dx^2*(yopt(2)-yold)^2;
if distSquared1 < distSquared2
    xn = xopt(2);
    yn = yopt(2);
else
    xn = xopt(1);
    yn = yopt(1);
end
end %MarchingNext
