function [vx,vy,vz] = TorusDeriv(toroid,poloid,hm,~,~,~,major,minor)
% Obtain the velocity at this parametrized torus point.

[kx,ky,kz] = Torus(toroid,poloid,0,0,0,major,minor);

% The centre of this slice is recovered using minor=0
[cx,cy,cz] = Torus(toroid,poloid,0,0,0,major,0);

% Velocity is hbar/m*kf where kf is the minor radius here and 
% the direction is outward from the centre of the torus, which is
% perpendicular to the surface.
%
% Do as you like, this is an example and I have no clue about the 
% energy functional, this is just a homogeneous velocity that satisfies
% the basic requirement of begin perpendicular to the surface.
vx = hm .* (kx-cx);
vy = hm .* (ky-cy);
vz = hm .* (kz-cz);

end %TorusDeriv
 