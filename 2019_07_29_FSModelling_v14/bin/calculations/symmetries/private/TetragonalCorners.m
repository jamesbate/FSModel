function points = TetragonalCorners(a, ~, c)
% Return the corners of the BZ
% Shape (3, 8), first xyz then points
points = OrthorhombicCorners(a, a, c);
end
