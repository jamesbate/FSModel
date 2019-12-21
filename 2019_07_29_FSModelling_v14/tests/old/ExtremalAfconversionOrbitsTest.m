classdef ExtremalAfconversionOrbitsTest < matlab.unittest.TestCase
% A test for extremal orbits where simple figures are taken and their
% extremal orbits are found. The path generated has multiple verifyable
% properties like its inclincation, but also the enclosed area.
% 
% Also tests that k space area => quantum oscillation frequency is 
% behaving as expected although simple.
    
    methods(TestMethodSetup)
        function AddToPath(~)
            AddModule('algorithms');
            AddModule('symmetries');
            AddModule('physics');
            AddModule('constants');
        end %AddToPath        
    end %methods
    
    methods(Test)
        function testAreaToFrequency(obj)
            % Test against memory that area=>freq is still valid
            % this does not interfere with the rest, in principle
            % the function as well as these tests generate the area
            % and then convert to frequency, but for the results to make
            % sense this has to work
            
            area = pi * 10^18;
            obj.verifyLessThan(abs(AreaToFrequency(area) - 329.105975), 1e-6);
            
        end
        
        function testCilindricalArea(obj)
            % Make sure cilinder with B//z has less than 0.1% deviation
            
            symm = 'Tetragonal';
            kf = GetKFermiFunc(symm);
            
            % Only k00 matters and this is always the first k parameter
            % however the number of k parameters has to be correct so
            % derive it here. All have signature (kz, psi, c, <kpara>)
            % hence the 3
            kpara = zeros(1, length(Signature(kf)) - 3);
            kpara(1) = 0.1e10;
            c = 5e-10;
            [~, ff] = ExtremalOrbits(symm, c, kpara, 0, 0);
            obj.verifyEqual(length(ff), 1);
            
            predict = AreaToFrequency(kpara(1)^2 * pi);
            obj.verifyLessThan(abs(predict - ff(1)) / predict, 1e-3);
        end %testCilindrical
        
        
        function testCilinderTiltedArea(obj)
           % Make sure cilinder area scales as 1/cos(theta) 
           % See testCilinderArea
            
            symm = 'Tetragonal';
            kf = GetKFermiFunc(symm);
            
            % Take some arbitrary angle
            bTheta = 47 / 180 * pi;
            kpara = zeros(1, length(Signature(kf)) - 3);
            kpara(1) = 0.1e10;
            c = 5e-10;
            [~, ff] = ExtremalOrbits(symm, c, kpara, bTheta, 0);
            obj.verifyEqual(length(ff), 1);
            freq = ff(1);
            
            % A cilinder cross sectional area turns elliptical
            % with the short axis the cilinder radius and the long
            % axis radius/cos(tilt angle) and ellipse areas are     
            % simply elongated circles A = pi a b
            predict = AreaToFrequency(kpara(1)^2 * pi / cos(bTheta));
            obj.verifyLessThan(abs(predict - freq) / predict, 1e-4);

            % Test the accuracy of the orbit traversed compared to the
            % expected elliptical orbit at inclination bTheta.
            [xx, yy, zz] = OrbitalPath(0, symm, c, kpara, bTheta, 0);
            angles = atan(zz ./ (xx - xx(1)));
            obj.verifyLessThan(max(abs(abs(angles) - bTheta)), 1e-10);
                        
            [x1, index1] = max(xx);
            [x2, index2] = min(xx);
            aAxis = sqrt((zz(index1) - zz(index2))^2 + (x2 - x1)^2);
            obj.verifyLessThan(abs(aAxis - 2 * kpara(1) / cos(bTheta)), 1e-4 * kpara(1));
            
            [y1, index1] = max(yy);
            [y2, index2] = min(yy);
            bAxis = sqrt((zz(index1) - zz(index2))^2 + (y2 - y1)^2);
            obj.verifyLessThan(abs(bAxis - 2 * kpara(1)), 1e-4 * kpara(1));
        end %testCilinderTiltedArea
        
        function testPsiDependence(obj)
            % Make sure the B axis rotates properly
            
            symm = 'Tetragonal';
            kf = GetKFermiFunc(symm);
            
            % Take some arbitrary angle
            bTheta = 47 / 180 * pi;
            bPsi = 131 / 180 * pi;
            kpara = zeros(1, length(Signature(kf)) - 3);
            kpara(1) = 0.1e10;
            c = 5e-10;

            % Test the accuracy of the orbit traversed compared to the
            % expected elliptical orbit at inclination bTheta.
            % Do so by finding the points of highest/lowest kz and 
            % comparing their position to what is expected
            % Note that z drops very low in azumithal direction aligned
            % with b in the ideal case.
            [xx, yy, zz] = OrbitalPath(0, symm, c, kpara, bTheta, bPsi);
            
            rr = sqrt(xx.^2 + yy.^2);
            [zmax, index1] = max(zz);
            [zmin, index2] = min(zz);
            inclination = atan((zmax - zmin) / (rr(index1) + rr(index2)));
            obj.verifyLessThan(abs(inclination - bTheta), 1e-5);
            
            % The B angle lies within the 2nd quadrant
            % So the point of lowest kz should be there as well
            direcMiniX = acos(xx(index2) / rr(index2));
            direcMiniY = acos(yy(index2) / rr(index2));
            direcMaxiX = acos(xx(index1) / rr(index1));
            direcMaxiY = acos(yy(index1) / rr(index1));
            
            obj.verifyTrue(direcMiniX > pi / 2);
            obj.verifyTrue(direcMiniY < pi / 2);
            obj.verifyTrue(direcMaxiX < pi / 2);
            obj.verifyTrue(direcMaxiY > pi / 2);
            
            % The above angles are not really all that nice to compare
            % because the min/max are very flat and very small wobbles
            % make it uncertain. But, the points where z crosses 
            % the equilibrium value are very accurate to see if the in
            % plane angle makes sense
            %
            % It is also known that the orbit starts at psi=0 and moves
            % in positive psi (counter clockwise) motion, meaning it will
            % encounter the minimum first (131 deg vs 311 deg).
            
            psi = acos(xx ./ rr);
            psi(yy < 0) = 2 * pi -  psi(yy < 0);
            
            obj.verifyLessThan(index2, index1);    
            avgZ = sum(zz)/length(zz);
            [~, index3] = min(abs(zz(index2:index1) - avgZ));
            index3 = index2 + index3;
            psi1 = psi(index3);
            obj.verifyLessThan(abs(psi1 - bPsi - pi/2), pi / 100);
            
        end %testPsiDependence
        
        function testStabilityHighTheta(obj)
            % Make sure the B axis rotates properly to at least 85 degrees
            % It also works for 89.5 but that is a really slow test.
            % This is a test on a distorted cilinder, but without z
            % corrugation the dependence has to be perfectly 1/cos(theta).
            
            symm = 'FeSeTetragonal';
            c = 3e-10;
            kf = GetKFermiFunc(symm);
            kpara = zeros(1, length(Signature(kf)) - 3);
            kpara(1) = 0.2e10;
            kpara(2) = 0.1e10;

            [~, ff0] = ExtremalOrbits(symm, c, kpara, 0, 0, 100);
            ff0 = ff0(1);

            angle = 85 / 180 * pi;
            [~, ff] = ExtremalOrbits(symm, c, kpara, angle, 0, 100);
            ff = ff(1) * cos(angle);
            
            obj.verifyLessThan(abs(ff0 - ff), ff0/1000);

        end %testStabilityHighTheta
        
    end %methods
end %ExtremalOrbitsTest
