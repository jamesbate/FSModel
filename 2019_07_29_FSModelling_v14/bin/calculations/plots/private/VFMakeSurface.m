function VFMakeSurface(x, y, z, vf)
% x meant to be in 'kx * pi/a' and similarly for y/z
% vf is in meters per second.
%
% Responsibility: Plot the actual Fermi velocity. Low level. Mutable.
% You can change this freely if you wish to change the representation.

surf(x, y, z, vf, ...
     'EdgeColor', 'none', ...
     'SpecularStrength', 1, ...
     'FaceAlpha', 1);
c = colorbar;
c.Label.String = 'Fermi v (m/s)';
c.Label.FontSize = FontSize;
c.FontSize = FontSize;
end
