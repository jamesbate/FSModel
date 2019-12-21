function [vx, vy, vz] = TriangularDeriv(kappa, psi, ~, ~, c, k00, k03, k06, k20, k31)
% Return the Fermi velocity at this point.
%
% Kappa and psi are the position along the z axis and azumithal angle.
% kz = (kappa - pi) / c
% hm = hbar / m


[kx, ky, ~] = Triangular(kappa, psi, 0, 0, c, k00, k03, k06, k20, k31);
kf = sqrt(kx^2+ky^2);

dpsi = -3 .* k03 .*               sin(3.*psi) +...
       -6 .* k06 .*               sin(6.*psi) +...
       -3 .* k31 .* sin(kappa) .* sin(3.*psi);


dz = -2 .* c .* k20 .* sin(2.*kappa)  +...
     c .* k31 .* cos(kappa) .* cos(3.*psi);

vx = hm .* (kf .* cos(psi) - dpsi .* sin(psi));
vy = hm .* (kf .* sin(psi) + dpsi .* cos(psi));
vz = hm .* kf .* dz;

end %TriangularDeriv
