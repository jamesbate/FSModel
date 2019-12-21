classdef ExtremePathTimeTest < matlab.unittest.TestCase
    
    methods(TestMethodSetup)
        function addCodePaths(obj)
            AddModule('symmetries');
            AddModule('constants');
            AddModule('physics');
            AddModule('algorithms');
        end
    end %methods
    
    methods  (Test)
        
    function testCilinderSimplePeriod(obj)
        % Make sure the timer is correct for a perfect 2D material at T=0
        % with B//z and B at a polar angle.
        %
        % This is the math:
        % Take a cilinder in k space, meaning its fermi velocity
        % is always simpley vf = hbar kf and kf is constant and 
        % vf is in the radial in plane direction. Then the rate 
        % of change of k is given by Newton (except for a sign):
        % hbar kdot = e cross(vf, B)
        % If the magnetic field is along z then it follows:
        % kdot = e/m kf B
        % Since kdot is a constant along the entire orbit, the time is
        % T = 2 pi kf / kdot = 2 pi m / e B
        % Using 5 T and m=m0 this results in 7.15 ps
        % Independent of kf!
        %
        % Polar angles are difficult because of the angle dependence
        % However there is a nice similarity.
        % When psi aligns with the field the velocity is 1/cos(theta)
        % times what it is when B is aligned with the z axis.
        % When you are orthogonal it is the same as the original,
        % but the curvature is 1/cos(theta) as flat.
        % This combination holds all along the orbit and hence 
        % there is a net 1/cos(theta) scaling.
        % Another way is using this:
        %   T = c/eH  dS/dE
        % where S is the area enclosed by the orbit.
        %   S = pi kf^2 /cos(theta)
        % Then the energy derivative really affects the kf^2 term
        % but not the cos(theta) term and hence if you look a the
        % scaling of T it is as 1/cos(theta).
        % 
                
        symm = 'FeSeTetragonal';
        kffunc = GetKFermiFunc(symm);
        nrKPara = length(Signature(kffunc)) - 3;
        kpara = zeros(1, nrKPara);
        kpara(1) = 0.2123476; %as long as >0, does not matter
        
        % Note that c really does not matter, but entering 0 
        % will result in 1/0 hence NaN and problems.
        % Arguments kz0, B, m, symmetry, c, kparameters, bTheta, bPhi)
        timer = OrbitalPeriod(0, 5, m0, symm, 3e-10, kpara, 0, 0);
        expect = 7.1453e-12;
        obj.verifyLessThan(abs(expect - timer), expect / 100);
        
        angle = 86/180*pi;
        timer = OrbitalPeriod(0, 5, m0, symm, 3e-10, kpara, angle, 0);
        expect = 7.1453e-12 / cos(angle);
        obj.verifyLessThan(abs(expect - timer), expect / 100);
        
        angle = 134/180*pi;
        timer = OrbitalPeriod(0, 5, m0, symm, 3e-10, kpara, angle, 0);
        expect = 7.1453e-12 / abs(cos(angle));
        obj.verifyLessThan(abs(expect - timer), expect / 100);     
    end %testCilinderSimple
    
    
    function testCorrugatedCilinderPeriod(obj)
        % As a result of the Fermi liquid electron approximation
        % The orbital time does NOT depend on the k parameters at all
        % because vf is directly proportional to the pathlength
        % locally, but then rotated by 90 degrees.
        % i.e. vf proportional to nabla_k(kf) but the local 
        % pathlength in linear approximation is also proportional 
        % to nabla_k(kf)
        
        symm = 'FeSeTetragonal';
        kffunc = GetKFermiFunc(symm);
        nrKPara = length(Signature(kffunc)) - 3;
        kpara = zeros(1, nrKPara);
        kpara(1) = 0.2123476; 
        
        timer = OrbitalPeriod(1e9, 5, m0, symm, 3e-10, kpara, 0, 0);        
        kpara(5) = 0.05; 
        kpara(4) = 0.05; 
        timer2 = OrbitalPeriod(1e9, 5, m0, symm, 3e-10, kpara, 0, 0);
        obj.verifyLessThan(abs(timer2 - timer), timer / 10000);
    end
    
    
    
    end %methods
    
    
end %ExtremePathTimeTest
