function [kx, ky, kz] = Hexagonal(kappa, psi, ~, ~, c, k00, k06, k012, k13, k20)
% Returns the Fermi surface position parametrized by (kappa, psi)
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
% These modes were made by Joseph Prentice back in 2016
%

kappa = kappa - pi;
kf = k00                               +...
     k06 .*               cos(6.*psi)  +...
     k012.*               cos(12.*psi) +...
     k13 .* sin(kappa) .* cos(3.*psi)  +...
     k20 .* cos(2.*kappa);
 
kx = kf .* cos(psi);
ky = kf .* sin(psi);
kz = kappa / c;
end %Hexagonal
