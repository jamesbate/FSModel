function [volume, err] = EnclosedVolume(func, delta, maxA, maxB)
% Given f(a,b) => [x,y,z] double-periodic in 2pi, get the volume enclosed.
% Measured by triangulation with respect to the centre of mass.
%
% func : function 
%   Takes 1 argument, periodic in 2 pi and returns [X, Y, Z]
%   also when the input is an array.
% delta : number
%   defaulted to 0.001, error to aim at, fractional
% maxA, maxB : number
%   maximum number of points to distribute over (0, 2pi)
%   defaulted to 1000
%   If reached, error.
% 
% The output error is absolute and half the last error obtained and 
%   expected to overestimate the actual error by a factor 2 because 
%   for smooth shapes this converges O(N^-2) and stepsize is doubled each
%   iteration. In practise this overestimates by ~50%.
%
% The A parameter may lead to an open end (cilinder axis), the B axis
% has to strictly return to itself.
%
% Responsibility: Error analysis and auto-converge over EnclosedVolumeDirect.
   

% Defaults
args = nargin;
if args < 2
    delta = 0.001;
end
if args < 3
    maxA = 1000;
end
if args < 4
    maxB = 1000;
end

% Loop till either max partitioning or error convergence for A
thisRes = 1e90;
lastRes = 1e99;
nrA = 10;
nrB = 10;
while nrA < maxA / 2 && abs(lastRes - thisRes) / thisRes > delta
    nrA = nrA * 2;
    lastRes = thisRes;
    thisRes = EnclosedVolumeDirect(func, nrA, nrB);
end %while

% Loop till either max partitioning or error convergence for B
lastRes = 1e99;
while nrB < maxB / 2 && abs(lastRes - thisRes) / thisRes > delta
    nrB = nrB * 2;
    lastRes = thisRes;
    thisRes = EnclosedVolumeDirect(func, nrA, nrB);
end %while

% Make a final step and determine the final error
volume = thisRes;
rough = EnclosedVolumeDirect(func, floor(nrA/2), floor(nrB/2));
err = abs(volume - rough) / 2;
if err / volume > delta
    error('No convergence: Volume fractional error %.3e, goal %.3e.', ...
          err/volume, delta);
end
end %EnclosedVolume
