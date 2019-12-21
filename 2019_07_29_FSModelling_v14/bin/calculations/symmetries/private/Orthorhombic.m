function [kx, ky, kz] = Orthorhombic(kappa, psi, ~, ~, c, k00, k02, k04, k10, k20, lin)
% Returns kf at a specific kz value at in plane angle psi 
% Implements the (lowest) allowed symmetry modes for ortho lattices
%
% kappa : number
%   0 to 2 pi
%   formulated here as kz = (kappa - pi) / c
% psi : number
%   0 to 2 pi
% c : number
%   lattice paramter in m
% k's: number
%   corrugation strengths in m^-1
%
% Please note that the Brillouin zone in kz is -pi N/c to pi N/c
% but this is not checked for.
%
% These modes were made by Joseph Prentice back in 2016
% Adjusted by Roemer Hinlopen such that linear is not a square root that 
% is finite, but straight up the absolute value.
%

kappa = kappa - pi;
kf = k00 +... 
     k02 .*               cos(2.*psi) + ...
     k04 .*               cos(4.*psi) + ...
     k10 .* cos(kappa)                + ...
     k20 .* cos(2.*kappa)             + ...
     lin .* abs(kappa);

kx = kf .* cos(psi);
ky = kf .* sin(psi);
kz = kappa / c;
 
end %Orthorhombic
