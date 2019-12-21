function points = TriangularCorners(a, ~, c)
% Return the corners of the Brillouin Zone.

f = 2 * pi / (3 * a);
g = pi / c;
points(1:3, 1) = [0, 2 * f / sqrt(3), g];
points(1:3, 2) = [-f, -f / sqrt(3), g];
points(1:3, 3) = [f, -f / sqrt(3), g];

points(1:3, 4:6) = points(1:3, 4:6);
points(3, 4:6) = -points(3, 4:6);

end %TriangularCorners
