function points = HexagonalCorners(a, ~, c)
% Return the corners of the Brillouin Zone.

f = 2 * pi / (3 * a);
g = pi / c;
points(1:3, 1) = [f, f / sqrt(3), g];
points(1:3, 2) = [0, 2 * f / sqrt(3), g];
points(1:3, 3) = [-f, f / sqrt(3), g];
points(1:3, 4) = [-f, -f / sqrt(3), g];
points(1:3, 5) = [0, -2 * f / sqrt(3), g];
points(1:3, 6) = [f, -f / sqrt(3), g];

points(1:3, 7:12) = points(1:3, 1:6);
points(3, 7:12) = -points(3, 7:12);
end %HexagonalCorners
