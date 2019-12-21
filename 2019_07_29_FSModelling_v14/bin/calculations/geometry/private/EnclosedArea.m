function [area, error, nr] = EnclosedArea(func, delta, maxN)
% Given f(a) => [x,y,z] periodic in 2pi, get the area enclosed by a period.
% Measured by triangulation with respect to the centre of mass.
%
% func : function 
%   Takes 1 argument, periodic in 2 pi and returns [X, Y, Z]
%   also when the input is an array.
% delta : number
%   defaulted to 0.001, error to aim at, fractional
% maxN : number
%   maximum number of points to distribute over (0, 2pi)
%   defaulted to 100000
%   Below 20 error is undefined.
% 
% The output error is absolute and half the last error obtained and 
%   expected to overestimate the actual error by a factor 2 because 
%   for smooth shapes this converges O(N^-2) and stepsize is doubled each
%   iteration. In practise this overestimates by ~50%.
% The actual N is returned to allow you to do repeats without requiring the
% full optimization procedure again callling EnclosedAreaDirect
% immediately.
%
% Responsibility: Error analysis and auto-converge over EnclosedAreaDirect.
%
%
% Became absolete with Geometry.
    

% Defaults
args = nargin;
if args < 2
    delta = 0.001;
end
if args < 3
    maxN = 100000;
end


% Loop till either max partitioning or error convergence
lastRes = 1e99;
thisRes = 1e90;
nr = 10;
while nr < maxN / 2 && abs(lastRes - thisRes) / thisRes > delta
    nr = nr * 2;
    lastRes = thisRes;
    thisRes = EnclosedAreaDirect(func, nr);
end %while


% Make a final step and determine the final error
nr = nr * 2;
rough = thisRes;
area = AreaEnclosedDirect(func, nr);
error = abs(area - rough) / 2;
end %EnclosedArea
