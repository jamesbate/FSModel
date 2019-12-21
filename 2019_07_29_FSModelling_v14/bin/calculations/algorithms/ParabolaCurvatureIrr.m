function k = ParabolaCurvatureIrr(x0, x1, x2, y0, y1, y2)
% Get the curvature in x1
% Expects x0, x1, x2 to be an interval around x1.
% y are self explanatory, the function values at these x values.

% Parabolic fit the quadratic coefficient
den = (x2-x0) * (x1-x0) * (x2-x1);
a = (y1-y0) * (x2-x0) - (y2-y0)*(x1-x0);
a = -a / den;

% Parabolic fit the linear coefficient
b = (y1-y0) * (x2-x0) * (x0+x2) - (y2-y0)*(x1-x0)*(x1+x0);
b = b / den;

% Find the curvature
k = 2 * a / (1+(2 * a * x1 + b)^2) ^ 1.5;

end


