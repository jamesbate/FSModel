function sigma = SigmaOffDiagonal(cg, vf, tau, B, isElectron)
% Create a matrix with diagonal 0 and off diagonal the sigma values.
% Integrates the L-space (velocity * tau) of the Fermi surface
% at this angle following Ong 1991.
% 
% cg : ComputationalGeometry for Fermi surface
% vf : function [R,R] => [R,R,R] of Fermi velocity
% tau : double or function [R,R]=>R for scattering time in seconds
% B : double for magnetic field
%

if isnumeric(tau)
    isfunc = false;
    tauNow = tau;
else
    try
        tau(0,0)
    catch
        error('Tau has to be a function of 2 variables or a constant.');
    end
    isfunc = true;
end

[aa, bb] = cg.Cover(200);
dd = cg.CalcDistance(aa,bb);

sigma = zeros(3,3);
integrationXY = 0;
integrationXZ = 0;
integrationYZ = 0;
for ind = 1:length(dd)-1
    if isnan(aa(ind)) || isnan(aa(ind+1))
        continue;
    end
    if isfunc
        tauNow = tau(aa(inda), bb(indb));
    end
    
    % Zero sized orbits are fine to ignore.
    try
        path = cg.CalcPath(aa(ind), bb(ind), true);
    catch exc
        if strcmp(exc.identifier, 'Marching:Starting')
            continue
        end
        rethrow(exc);
    end
        
    % Calculate the L-orbit here
    [vx, vy, vz] = vf(path(:,1), path(:,2));
    lx = vx .* tauNow;
    ly = vy .* tauNow;
    lz = vz .* tauNow;
    
    % Calculate how much weight it has.
    % We have integral dk_B/2pi where k_B runs along the field
    % i.e. distance / dd
    % to accomodate for changes along B.
    weight = (dd(ind+1) - dd(ind)) / (2*pi);
    scale = max([max(abs(lx)), max(abs(ly)), max(abs(lz))]);
    
    % Now integrate this L-orbit's area in each projections
    % Each should be really just a call to ComputeArea, were it not 
    % for the fact that numerical precision errors can make the 
    % orbit seem to not be closed when the area is really 0
    % and this is what the catch clause is for.
    try
        LareaXY = ComputeArea(lx, ly, zeros(1, length(lx)));
    catch exc
        if max(lx) - min(lx) > 0.001 * scale && ...
           max(ly) - min(ly) > 0.001 * scale
            rethrow(exc);
        end
        LareaXY = 0;
    end
    
    try
        LareaXZ = ComputeArea(lx, zeros(1, length(lx)), lz);
    catch exc
        if max(lx) - min(lx) > 0.001 * scale && ...
           max(lz) - min(lz) > 0.001 * scale
            rethrow(exc);
        end
        LareaXZ = 0;
    end
       
    try
        LareaYZ = ComputeArea(zeros(1, length(lx)), ly, lz);
    catch exc
        if max(ly) - min(ly) > 0.001 * scale && ...
           max(lz) - min(lz) > 0.001 * scale
            rethrow(exc);
        end
        LareaYZ = 0;
    end
    
    integrationXY = integrationXY + LareaXY * weight;
    integrationXZ = integrationXZ + LareaXZ * weight;
    integrationYZ = integrationYZ + LareaYZ * weight;
end

% Convert to sigma values
const = 2 * e^3 * B / (hbar^2 * 4 * pi^2);
sigma(1, 2) = const * integrationXY;
sigma(2, 1) = sigma(1, 2);
sigma(1, 3) = const * integrationXZ;
sigma(3, 1) = sigma(1, 3);
sigma(2, 3) = const * integrationYZ;
sigma(3, 2) = sigma(2, 3);

% Note that because this is lowest order, the rotation direction
% of the electrons around their paths really does not matter at all,
% the sign can be just stuck on.
if isElectron
    sigma = -sigma;
end
end %SigmaOffDiagonal

