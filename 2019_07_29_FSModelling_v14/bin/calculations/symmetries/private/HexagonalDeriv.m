function [vx, vy, vz] = HexagonalDeriv(kappa, psi, hm, ~, ~, c, k00, k06, k012, k13, k20)
% Return the Fermi velocity at this point.
%
% Kappa and psi are the position along the z axis and azumithal angle.
% kz = (kappa - pi) / c
% hm = hbar / m

[kx, ky, ~] = Hexagonal(kappa, psi, 0, 0, c, k00, k06, k012, k13, k20);
kf = sqrt(kx^2+ky^2);

kappa = kappa - pi;
dpsi = -6  .* k06  .* sin(6.*psi)   + ...
       -12 .* k012 .* sin(12 .*psi) + ...
        -3 .* k13  .* sin(kappa) .* sin(3.*psi);
 
dz = c .* cos(kappa) .* k13 .* cos(3 .* psi)+...
     -2 .* c .* sin(2 .* kappa) .* k20;
 
 
vx = hm .* (kf .* cos(psi) - dpsi .* sin(psi));
vy = hm .* (kf .* sin(psi) + dpsi .* cos(psi));
vz = hm .* dz;

end %HexagonalDeriv
