function gamma = HeatCapacity2d(band)
% Return the linear heat capacity coefficient in J/mol/K^2
%
% ! the input has to have passed InitiateBands already !


% Cv = pi^2/3 k_B^2 T g(E_F)
%
% The density of states g for a 2d system:
% fractional band filling is the k space Fermi surface volume (term 1)
% devided by the total number of spots in the band (term2)
% multiplied by 2 (spin deg)
% g1 is the DoS contribution of 1 band
% f = pi kf^2 2 pi/c * Vu/8pi^3 * 2
% g1 = d(f/Vu)/dE = d(f/Vu)/d(kf^2) * 2m/hbar^2
% g1 = m/pi c hbar^2 in 1/m^3J
% g1 = m N_A Vu / Nu pi c hbar^2 
%
% gamma = pi a b volFact() N_A k_B^2 / (3 hbar^2 Nu) sum(m)
%
% This is as reported in PRB 91, 155106 2015 for FeSe
% and the volume factor, which is 1 for tetragonal 0.5 for hexagonal

symm = band('symmetry');
nrAtoms = band('atomspercell');

gamma = pi * band('a') * band('b') * VolumeFactor(symm) * Avogadro * kb^2;
gamma = gamma / (3 * hbar^2 * nrAtoms) * band('effmass');

end %HeatCapacity2d