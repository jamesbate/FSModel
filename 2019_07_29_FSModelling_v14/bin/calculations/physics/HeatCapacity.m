function gamma = HeatCapacity(geo, vfunc, Vunit, Nunit)
% Integrate the density of states over the Fermi surface to obtain 
% the heat capacity for this Fermi surface.
%
% See the report for the math.
% Only requires Geometry, though ComputationalGeometry works also.
%
% vfunc is [a,b] => velocity vector.
% Vunit is the unit cell volume.
% Nunit is the number of atoms per unit cell.

gamma = kb^2 * Avogadro() * Vunit / (12 * pi * hbar() * Nunit);
aa = (0:2*pi/HeatCapacityPrecision():2*pi);
bb = (0:2*pi/HeatCapacityPrecision():2*pi);

% Integrate 1/vf over the Fermi surface area.
integral = 0;
for inda = 1:length(aa) - 1
 
    % Query the velocity in large amounts for performance
    arep = repmat(aa(inda),1,length(bb));
    [vx, vy, vz] = vfunc(arep, bb);
    vf = sqrt(vx.^2 + vy.^2 + vz.^2);
    
    % Compute the distance between neighbouring points, in both 
    % the a and b direction, because this determines the area element dS.
    arep2 = repmat(aa(inda+1),1,length(bb));
    [xx, yy, zz] = geo.Points(arep, bb);
    [xx2, yy2, zz2] = geo.Points(arep2, bb);
    shiftA = zeros(length(bb) - 1, 3);
    shiftA(:,1) = xx2(1:end-1) - xx(1:end-1);
    shiftA(:,2) = yy2(1:end-1) - yy(1:end-1);
    shiftA(:,3) = zz2(1:end-1) - zz(1:end-1);
    shiftB = zeros(length(bb) - 1, 3);
    shiftB(:,1) = xx(2:end) - xx(1:end-1);
    shiftB(:,2) = yy(2:end) - yy(1:end-1);
    shiftB(:,3) = zz(2:end) - zz(1:end-1);
    
    % The actual integration.
    for indb = 1:length(bb) - 1
        dS = norm(cross(shiftA(indb,:), shiftB(indb,:)));
        integral = integral + dS / vf(indb);
    end
end

gamma = gamma * integral;
end %HeatCapacity
