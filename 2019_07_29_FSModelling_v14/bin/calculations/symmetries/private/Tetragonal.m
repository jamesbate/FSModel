function [kx, ky, kz] = Tetragonal(kappa, psi, ~, ~, c, k00, k04, k12, k16, k110)
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
     k04  .*               cos(4 .*psi)+...
     k12  .* cos(kappa) .* sin(2 .*psi)+...
     k16  .* cos(kappa) .* sin(6 .*psi)+...
     k110 .* cos(kappa) .* sin(10.*psi);

kx = kf .* cos(psi);
ky = kf .* sin(psi);
kz = kappa / c;
end %Tetragonal
