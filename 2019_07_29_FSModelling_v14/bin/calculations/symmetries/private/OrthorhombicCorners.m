function points = OrthorhombicCorners(a, b, c)
% Return the corners of the BZ
% Shape (3, 8), first xyz then points

points = zeros(3, 8);
points(1:3, 1) = [pi/a, pi/b, pi/c];
points(1:3, 2) = [-pi/a, pi/b, pi/c];
points(1:3, 3) = [-pi/a, -pi/b, pi/c];
points(1:3, 4) = [pi/a, -pi/b, pi/c];

points(1:3, 5:8) = points(1:3, 1:4);
points(3, 5:8) = -points(3, 5:8);

end
