classdef SigmaDrudeTest < matlab.unittest.TestCase
    
methods (Test)
    function TestSigmaDrude2D(obj)
        % Take a perfect cilinder with B at an angle and get the sigma tensor, 
        % then compare, then make sure the scaling with angle is as
        % cos(theta) as expected (only the Bz component contributes to
        % sigma xy)
        
        global DETAILED;
        if ~isempty(DETAILED) && ~DETAILED
            return;
        end
        
        band = containers.Map();
        band('tau') = 100e-12;
        band('symmetry') = 'FeSeTetragonal';
        band('a') = 3e-10;
        band('b') = 3e-10;
        band('c') = 5e-10;
        band('kcoeff') = [0.3, 0, 0, 0, 0, 0, 0].*1e10;
        band('type') = 'hole';
        band('precision') = 200;
        band('effmass') = m0;
        band('BPolar') = 73/180*pi;
        band('BAzumithal') = 0;
        band('B') = 1;
        band('atomspercell') = 1;
        band('id') = '01';
        
        [sigma, RHall] = MultiSigma({band});
        
        % Compute the drude model equivalent sigma matrix to compare
        % 2 in n for spin
        sigmaD = zeros(3, 3);
        frac = MultiFractionalFilling({band}, false);
        n = frac / (band('a')*band('b')*band('c')) * 2;

        omegac = e * band('B') * cos(band('BPolar')) / band('effmass');
        sigmaD(1, 2) = omegac * n * e^2 * band('tau')^2 / band('effmass');
        sigmaD(2, 1) = sigmaD(1, 2);
        sigmaD(1, 1) = n * e^2 * band('tau') / band('effmass');
        sigmaD(2, 2) = sigmaD(1, 1);
        
        obj.verifyLessThan(max(max(abs(sigma - sigmaD))), sigmaD(1,1)/100);

        % And the hall coefficient to verify both even stronger,
        % because everyone knows this result to be correct even more than
        % the above.
        RH = sigmaD(2, 1) / (band('B') * sigmaD(1, 1)^2 * cos(band('BPolar')));
        obj.verifyLessThan(abs(RH - 1/(n*e)), 0.0001/(n*e));
        obj.verifyLessThan(abs(RH - RHall), RHall / 1000);

    end %TestSigmaDrude2D
    
    function TestSigmaDrude3D(obj)
        % Test drude against this implementation for a sphere.
        
        global DETAILED;
        if ~isempty(DETAILED) && ~DETAILED
            return;
        end
       
        R = 5e9;
        function [x,y,z] = Sphere(a,b)
            x = R .* cos(b).*sin(a./2);
            y = R .* sin(b).*sin(a./2);
            z = R .* cos(a./2);
        end
        
        function [vx,vy,vz] = VSphere(a,b)
            [x,y,z] = Sphere(a,b);
            vx = hbar/m0 .* x;
            vy = hbar/m0 .* y;
            vz = hbar/m0 .* z;
        end
        
        B = 1;
        tau = 100e-12;
        
        % What it has to be
        volume = 4/3*pi*R^3;
        n = volume / (4*pi^3);
        omegac = e * B / m0;
        sOff = omegac * n * e^2 * tau^2 / m0;
        sOn = n * e^2 * tau / m0;
        
        % Field along z => sigma xy
        cg = ComputationalGeometry(Geometry(@Sphere, 200));
        cg.SetDirection(0,0);
        sigma = SigmaDiagonal0(cg, @VSphere, tau);
        sigma = sigma + SigmaOffDiagonal(cg, @VSphere, tau, B, false);
        sigmaD(1,:) = [sOn,sOff,0];
        sigmaD(2,:) = [sOff,sOn,0];
        sigmaD(3,:) = [0,0,sOn];
        obj.verifyLessThan(max(max(abs(sigmaD-sigma))), sOff/100);
        
        % Field along x => sigma yz
        % Do not make an orbit go over 2 poles at once at a symmetry point
        % this is not a test for topology, it is for Sigma
        cg.SetDirection(88/180*pi,0);
        sigma = SigmaDiagonal0(cg, @VSphere, tau);
        sigma = sigma + SigmaOffDiagonal(cg, @VSphere, tau, B, false);
        sigmaD(1,:) = [sOn,0,0];
        sigmaD(2,:) = [0,sOn,sOff];
        sigmaD(3,:) = [0,sOff,sOn];
        obj.verifyLessThan(max(max(abs(sigmaD-sigma))), sOff/10);
        
        % Field along y => sigma xz
        % Do not make an orbit go over 2 poles at once at a symmetry point
        % this is not a test for topology, it is for Sigma
        cg.SetDirection(88/180*pi,88/180*pi);
        sigma = SigmaDiagonal0(cg, @VSphere, tau);
        sigma = sigma + SigmaOffDiagonal(cg, @VSphere, tau, B, false);
        sigmaD(1,:) = [sOn,0,sOff];
        sigmaD(2,:) = [0,sOn,0];
        sigmaD(3,:) = [sOff,0,sOn];
        obj.verifyLessThan(max(max(abs(sigmaD-sigma))), sOff/10);
        
    end
end %methods
end %SigmaDrudeTest



