function volume = EnclosedVolumeDirect(func, nrA, nrB, plot)
% Given f(A, B) => [x,y,z] periodic in 2pi, get the volume enclosed.
% A *may* end in an open end, B *has* to be periodic
%
% Input
% -----
% func : function
%   Takes 2 arguments between 0 and 2 pi
%   Returns [X, Y, Z], also when A and B are equally long arrays.
%   A can end in an open end (e.g. cilinder axis)
%   B has to be periodic (e.g. ellipse or something more complicated)
% nrA, nrB : int
%   Number of points to use along the A/B dimension.
% plot (optional) : bool
%   Defaults to false
%   If set, plot equal-A orbits on a new figure.
%   Only plots 1 in 10 orbits as it tends to be too much otherwise.
%   This is only a debugging tool / understanding tool and hence not 
%   much specification is possible.
%
% Algorithm
% ---------
% Step over A
% Each time consider the area at this A value and the last
% by looping B. Determine the height between the orbits by using a weight
% average. The volume of that iteration is then area * height.
%
% The weight average means h = height_centre/3 + 2*height_edge/3
% This formula is obtained by adding a weight 'radius' to each point
% walking out from the centre. This is done because these are orbits and so
% a local circular approximation is the lowest order. dPhi cannot be used
% without the Jacobian term radius. This results in the above formula
% instead of (h_centre + h_edge)/2 if no radial weight was added.
% The area is the average between the current and previous.
% 
% Responsibility: Combine func, EnclosedAreaOrbit and Height.

% Defaults
if nargin < 4
    plot = false;
elseif plot
    figure;
end


% Initialize for the first A value
A = (0:2*pi/nrA:2*pi);
flatA = ones(1, nrB + 1) .* A(1);
discrete = (0:2*pi/nrB:2*pi);
[X, Y, Z] = func(flatA, discrete);
area = EnclosedAreaImplementation(X, Y, Z);
volume = 0;

% Loop over the remainder
for ind = 2:length(A)
    
    % 1) Calculate the new orbit at this A value
    discrete = (0:2*pi/(nrB-1):2*pi);
    flatA = ones(1, nrB) .* A(ind);
    
    prevX = X;
    prevY = Y;
    prevZ = Z;
    prevArea = area;
    [X, Y, Z] = func(flatA, discrete);
    
    % 2) Calculate the volume enclosed with the last one.
    area = EnclosedAreaImplementation(X, Y, Z);
    height = EnclosedVolumeHeight(X, Y, Z, prevX, prevY, prevZ);
    volume = volume + height * (area + prevArea) / 2;
    
    % 3) Consider plotting this orbit.
    if plot && mod(ind, 10) == 0
        plot3(X, Y, Z);
        hold on;
    end
end %for
end %EnclosedVolumeDirect
