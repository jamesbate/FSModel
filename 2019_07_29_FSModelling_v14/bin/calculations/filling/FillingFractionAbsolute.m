function [n, dn] = FillingFractionAbsolute(symmetry, a, b, c, kparameters, ...
                                           precision, err)
% Fractional filling of a band || mind *per spin direction*
% Determined by integration of a corrugated quasi-2D Fermi surface
% Only positive, there is no sign for holes/electrons here.
%
% symmetry : string
%   One of the symmetries implemented in the bin/symmetries directory.
% a, b, c : number
%   lattice parameter, in A
%   Please note that a and b are only used for the total BZ volume,
%   not for the volume of the pocket itself (encoded by angles and
%   corrugation). So for hexagonal lattices, please exploit this 
%   to set b = 0.5 * a to account for the fact that BZ is 0.5 * a^2 * c
%   same of course holds for triangular lattices.
% kparameters : array of numbers
%   the corrugation values in order
% precision : int
%   Precision for Geometry, about 100-200.
% err : double
%   absolute maximum allowable fractional error. Default 0.01.
% return : n : number
%   the number of electrons within the unit cell.
%

kf = QueryKfVf(symmetry, a, b, c, kparameters);
geo = Geometry(kf, precision);
[kVolumePocket, actualErr] = geo.CalcVolume(err);

if actualErr / kVolumePocket > err
    error('EnclosedVolume did not converge, error %.2e%%', ...
          actualErr/kVolumePocket);
end

% The volume is 8pi^3 not 4pi^3 because this function does not 
% take spin degeneracy into account. 
% Alternatively, see it as fractional filling. This number varies 0 to 1
% and not 0 to 2 which it would be if you consider spin degeneracy
% in which case a full band represents 2 electrons per unit cell.
vfact = VolumeFactor(symmetry);
rSpaceCellVolume = a * b * c * vfact / (8 * pi^3);
n = kVolumePocket * rSpaceCellVolume;
dn = actualErr * rSpaceCellVolume;
end %NumberElectrons
