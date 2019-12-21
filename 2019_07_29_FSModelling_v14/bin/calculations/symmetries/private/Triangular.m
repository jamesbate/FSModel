function [kx, ky, kz] = Triangular(kappa, psi, ~, ~, c, k00, k03, k06, k20, k31)
% Returns kf at a specific kz value at in plane angle psi 
% Implements the (lowest) allowed symmetry modes for triangle lattices
%
% kz : number           (z component of k, A^-1)
% psi : number          (in plane angle, radians)
% c : number            (lattice in A)
% k's: number           (the strength of each corrugation, in A^-1)
%
% Please note that the Brillouin zone in kz is -pi N/c to pi N/c
% but this is not checked for.
%
% These modes were made by Joseph Prentice back in 2016
%

kappa = kappa - pi;
kf = k00 +...
     k03 .*               cos(3.*psi) +...
     k06 .*               cos(6.*psi) +...
     k20 .* cos(2.*kappa)             +...
     k31 .* sin(kappa) .* cos(3.*psi);

kx = kf .* cos(psi);
ky = kf .* sin(psi);
kz = kappa / c;

end %Triangular
