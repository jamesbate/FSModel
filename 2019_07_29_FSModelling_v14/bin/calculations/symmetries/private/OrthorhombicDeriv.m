function [vx, vy, vz] = OrthorhombicDeriv(kappa, psi, hm, ~, ~, c, k00, k02, k04, k10, k20, lin)
% Return the Fermi velocity at this point.
%
% Kappa and psi are the position along the z axis and azumithal angle.
% kz = (kappa - pi) / c
% hm = hbar / m


[kx, ky, ~] = Orthorhombic(kappa, psi, 0, 0, c, k00, k02, k04, k10, k20, lin);
kf = sqrt(kx^2+ky^2);

kappa = kappa - pi;
dpsi = -2 .* k02 .* sin(2.*psi)  + ...
       -4 .* k04 .* sin(4 .*psi);
 
dz = -c .* sin(kappa) .* k10           + ...
     -2 .* c .* sin(2 .* kappa) .* k20 + ...
     lin .* kappa ./ abs(kappa);
 
 
vx = hm .* (kf .* cos(psi) - dpsi .* sin(psi));
vy = hm .* (kf .* sin(psi) + dpsi .* cos(psi));
vz = hm .* kf .* dz;

end %OrthorhombicDeriv
