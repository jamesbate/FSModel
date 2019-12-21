function [RH, n] = FillingHallSimple(fraction, band)
% Get the Hall coefficient (m^3/C) and density (cm^-3) from frac filling.
%
% PLEASE note that this is just single-band 1/nq. If you enter the sum
% of many bands, know that your assumption is that all of them have
% the same mobility, which is generally wrong.
%

symm = band('symmetry');

% Real space volume of a unit cell in m^3
% Complete band filling corresponds to 1 electron per unit cell all over
% the crystal, hence to a density 1/realSpaceVol
% Factor 2 in n is for spin degeneracy.
realSpaceVol = VolumeFactor(symm) * band('a') * band('b') * band('c');
n = fraction / realSpaceVol * 2;
RH = 1/(n*e);
n = n / 1e6;

end %ConvertHallAndDensity
