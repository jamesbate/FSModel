function [kx, ky, kz] = FeSeTetragonal(kappa, psi, ~, ~, c, k00, k02, k04, k12, k14, k10, k20)
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
% FeSe modes can be found in Bergemann 2003 review of Sr2RuO4, page 650
%

kappa = kappa - pi;

kf = k00 + ...
     k02 .*               sin(2.*psi) +...          
     k04 .*               cos(4.*psi) +...
     k12 .* cos(kappa) .* sin(2.*psi) +...
     k14 .* cos(kappa) .* cos(4.*psi) +...
     k10 .* cos(kappa)                +...
     k20 .* cos(2.*kappa);

 kx = kf .* cos(psi);
 ky = kf .* sin(psi);
 kz = kappa / c;
 
end %FeSeTetragonal
