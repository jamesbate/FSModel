function x = ParabolaFitIrr(x0, x1, x2, y0, y1, y2)
% Use a parabolic fit to find the location of the extremum

% Parabolic fit the quadratic coefficient
den = (x2-x0) * (x1-x0) * (x2-x1);
a = (y1-y0) * (x2-x0) - (y2-y0)*(x1-x0);
a = -a / den;

% Parabolic fit the linear coefficient
b = (y1-y0) * (x2-x0) * (x0+x2) - (y2-y0)*(x1-x0)*(x1+x0);
b = b / den;

x = -b/(2*a);
end