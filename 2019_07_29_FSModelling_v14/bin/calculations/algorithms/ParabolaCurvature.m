function curvature = ParabolaCurvature(x0, dx, y1, y2, y3)
% See ParabolaFit. Instead of the extreme, find the curvature at x0.
% Only equal to y'' if x0 is a maximum exactly.

% 11/06/2019
% Generalize this function and take this version out in favour of the 
% generalized one to remove duplicate code to test.
%H = y1 + y3 - 2*y2;
%a = H / (2 * dx ^ 2);
%b = (y3 - y1) / (2 * dx) - x0 * H / dx ^ 2;
%curvature = 2 * a / (1+(2 * a * x0 + b)^2) ^ 1.5;

curvature = ParabolaCurvatureIrr(x0-dx, x0, x0+dx, y1, y2, y3);

end
