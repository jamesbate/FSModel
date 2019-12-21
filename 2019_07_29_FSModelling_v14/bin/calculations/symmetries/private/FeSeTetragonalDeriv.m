function [vx, vy, vz] = ...
    FeSeTetragonalDeriv(kappa, psi, hm, ~, ~, c, k00, k02, k04, k12, k14, k10, k20)
% Return the Fermi velocity at this point.
%
% Kappa and psi are the position along the z axis and azumithal angle.
% kz = (kappa - pi) / c
% hm = hbar / m


[kx, ky, ~] = FeSeTetragonal(kappa, psi, 0, 0, c, k00, k02, k04, k12, k14, k10, k20);
kf = sqrt(kx.^2+ky.^2);

kappa = kappa - pi;
dpsi =  2 .* k02  .* cos(2.*psi) + ...
       -4 .* k04  .* sin(4 .*psi) + ...
        2 .* k12  .* cos(kappa) .* cos(2 .*psi) + ...
       -4 .* k14  .* cos(kappa) .* sin(4 .*psi);
 
dz = -c .* sin(kappa) .* k12 .* sin(2 .* psi)+...
     -c .* sin(kappa) .* k14 .* cos(4 .* psi)+...
     -c .* sin(kappa) .* k10 +...
     -2 .* c .* sin(2 .* kappa) .* k20;
  
vx = hm .* (kf .* cos(psi) - dpsi .* sin(psi));
vy = hm .* (kf .* sin(psi) + dpsi .* cos(psi));
vz = hm .* kf .* dz;
end %FeSeTetragonalDeriv
