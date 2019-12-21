function x = VolumeFactor(symmetry)
% Return x where volume of the unit cell is 'x*a*b*c'
% Equivalently, where Brillouin volume is '8pi^3/abcx' per spin direction

if strcmp(symmetry, 'Hexagonal')
    x = 0.5;
elseif strcmp(symmetry, 'Triagonal')
    x = 0.5;
elseif strcmp(symmetry, 'Tetragonal')
    x = 1;
elseif strcmp(symmetry, 'Orthorhombic')
    x = 1;
elseif strcmp(symmetry, 'FeSeTetragonal')
    x = 1;
elseif strcmp(symmetry, 'Torus')
    x = 1;
else
    error('There is no volume factor implemented for %s.', symmetry);
end
end %VolumeFactor