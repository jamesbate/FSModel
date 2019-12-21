function [gamma, gamma2d] = MultiGamma(bands)
% Compute the linear heat capacity coefficient in two ways.
%
% gamma is the accurate description mathematically, using the 
% density of states and relying on Fermi surface coverage as well as 
% inverse velocity.
%
% gamma2d on the contrary is really straightforward and only depends 
% on the masses, useful as a check, especially for quasi-2d cases.
%
% Both are returned as arrays matching the bands.

bands = InitiateBands(bands);

gamma2d = zeros(1, length(bands));
gamma = zeros(1, length(bands));
for ind = 1:length(bands)
    band = bands{ind};
    [cg, vfunc] = GeometryFromBand(band);
    Vunit = band('a') * band('b') * band('c') * VolumeFactor(band('symmetry'));
    gamma(ind) = HeatCapacity(cg, vfunc, Vunit, band('atomspercell'));
    gamma2d(ind) = HeatCapacity2d(bands{ind});
end

end %MultiGamma
