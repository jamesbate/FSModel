function [x, y, z] = FSTransformCoordinates(band, x, y, z)
% Rotate with the offsets and put in the offsets themselves

kxoff = band('kxoff');
kyoff = band('kyoff');
kzoff = band('kzoff');

if kxoff == 0 && kyoff == 0
    angle = 0;
else
    angle = acos(kxoff / sqrt(kxoff^2 + kyoff^2));
    if kyoff < 0
        angle = -angle;
    end
end

% Rotate everything with -angle
% Then what is originally the x axis stays now in the radial direction
% This is not so relevant for tetragonal where you move to the corner,
% but it is relevant for hexagonal where you move 60 degrees and cannot
% have your Fermi surface somehow violating the crystal symmetry.
xold = x;
x =  cos(angle) * x + sin(angle) * y;
y = -sin(angle) * xold + cos(angle) * y;

x = (x + kxoff) .* band('a') / pi;
y = (y + kyoff) .* band('b') / pi;
z = (z + kzoff) .* band('c') / pi;

end

