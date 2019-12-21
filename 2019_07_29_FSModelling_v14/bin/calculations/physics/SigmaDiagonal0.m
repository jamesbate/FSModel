function sigma = SigmaDiagonal0(cg, vf, tau)
% Get the 0-field diagonal elements of the conductivity tensor.
%
% cg : ComputationalGeometry [see elsewhere]
% vf : function (a,b) => [vx, vy, vz]
% tau : constant OR function(a,b) => tau
% sigma : 3x3 matrix with diagonal elements the sigma values (off = 0)
%
% The conductivity tensor depends only on the geometry and fundamental 
% constants of nature, nothing else. It is linear in tau. 
%
% Just to emphasize: This function works for both anistropic and isotropic
% tau and figures out which one you entered.

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

integrationXX = 0;
integrationYY = 0;
integrationZZ = 0;
aa = (0:2*pi/100:2*pi);
bb = (0:2*pi/100:2*pi);
for inda = 1:length(aa)-1
    for indb = 1:length(bb)-1
        [xx, yy, zz] = cg.Points([aa(inda), aa(inda), aa(inda+1)], ...
                                 [bb(indb), bb(indb+1), bb(indb)]);
        dr1 = [xx(2)-xx(1), yy(2)-yy(1), zz(2)-zz(1)];
        dr2 = [xx(3)-xx(1), yy(3)-yy(1), zz(3)-zz(1)];
        dS = norm(cross(dr1, dr2));
        
        if isfunc
            tauNow = tau(aa(inda), bb(indb));
        end
        
        [vx, vy, vz] = vf(aa(inda), bb(indb));
        term = tauNow / sqrt(vx^2+vy^2+vz^2);
        integrationXX = integrationXX + dS * vx^2 * term;
        integrationYY = integrationYY + dS * vy^2 * term;
        integrationZZ = integrationZZ + dS * vz^2 * term;
    end 
end

sigma = zeros(3,3);
sigma(1,1) = e^2 / (4*hbar*pi^3) * integrationXX;
sigma(2,2) = e^2 / (4*hbar*pi^3) * integrationYY;
sigma(3,3) = e^2 / (4*hbar*pi^3) * integrationZZ;
end %SigmaDiagonal
