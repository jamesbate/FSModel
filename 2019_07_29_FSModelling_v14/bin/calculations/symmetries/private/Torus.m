function [kx,ky,kz] = Torus(toroid,poloid,~,~,~,major,minor)
% Implements the parametrization of a toroidal surface.

kx = (minor .* cos(poloid) + major) .* cos(toroid);
ky = (minor .* cos(poloid) + major) .* sin(toroid);
kz = minor .* sin(poloid);

end %Torus
