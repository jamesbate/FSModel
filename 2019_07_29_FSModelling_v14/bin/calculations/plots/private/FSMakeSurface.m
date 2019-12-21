function FSMakeSurface(x, y, z, type)
% x meant to be in 'kx * pi/a' and similarly for y/z
% You may provide a color directly instead of providing the type.
% Type is ordinarily 'electron' or 'hole'
%
% Responsibility: Plot the actual Fermi surface. Low level. Mutable.
% You can change this freely if you wish to change the representation.

if strcmp(type, 'hole')
    color = 'blue';
elseif strcmp(type, 'electron')
    color = 'red';
else
    color = type;
end

surf(x, y, z, ...
     'Facecolor', color, ...
     'EdgeColor', 'none', ...
     'SpecularStrength', 1, ...
     'FaceAlpha', 0.5);
end

