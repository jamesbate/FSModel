function [vx, vy, vz] = ...
    TetragonalDeriv(kappa, psi, hm, ~, ~, c, k00, k04, k12, k16, k110)
% Return the gradient in cilindrical coordinates. 
% kz & psi can be numbers or identically shaped matrices/vectors
%
% The gradient is defined as [1, dkpsi/(kf dpsi), dpsi/kz]
% The first element is not returned as it is just 1 and self-explanatory
% as it is d (kf in plane)/d (kf in plane)
% This directly translates into the Fermi velocity.
% vf = hbar kf (1, -dkf/(kf dpsi), -dkf/dkz)
% Where kf is the radius IN PLANE
    
         
[kx, ky, ~] = Tetragonal(kappa, psi, 0, 0, c, k00, k04, k12, k16, k110);
kf = sqrt(kx^2+ky^2);

kappa = kappa - pi;

dpsi = -4 .* k04  .* sin(4 .*psi) + ...
        2 .* k12  .* cos(kappa) .* cos(2 .*psi) + ...
        6 .* k16  .* cos(kappa) .* cos(6 .*psi) + ...
       10 .* k110 .* cos(kappa) .* cos(10.*psi);
dpsi = dpsi .* (kf .^-1);
 
dz = -c .* sin(kappa) .* (k12 .* sin(2 .* psi)+...
                          k16 .* sin(6 .* psi)+...
                          k110 .* sin(10.* psi));
                        
vx = hm .* (kf .* cos(psi) - dpsi .* sin(psi));
vy = hm .* (kf .* sin(psi) + dpsi .* cos(psi));
vz = hm .* kf .* dz;
end %TetragonalDeriv
