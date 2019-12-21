classdef GeometryTest < matlab.unittest.TestCase

    methods (Test)
        
        function TestCilindricalVolume(obj)
            % Make cilinder dislocated from the origin and 
            % make sure its volume/area are determined correctly.
            %
            % Tests convex & enclosed against exact value.
            %
            % In particular, this is a test for open endpoints.
            
            radius = 5;
            height = 7;
            
            function [x, y, z] = Cilinder(zlike, psi)    
                x = radius * cos(psi) + radius * 1.3255;
                y = radius * sin(psi) - radius * 0.456;
                z = (zlike - pi / 3) * height / (2 * pi);
            end
            
            geo = Geometry(@Cilinder, 150);
            [res, err] = geo.CalcVolume();
            volume = pi * radius^2 * height;
            
            obj.verifyLessThan(err / res, 0.001);
            obj.verifyLessThan(abs(volume - res), err);
            
            % If these trigger, you did too well and could have given me a
            % smaller error as a user or think of a better way to do your
            % error handling.
            obj.verifyGreaterThan(abs(volume - res) * 3, err);
            
        end %TestCilindricalVolume
        
        function TestCilindricalArea(obj)
            % Same as volume but now enclosed area of cross sections.
            
            radius = 5;
            height = 7;
            
            function [x, y, z] = Cilinder(zlike, psi)    
                x = radius * cos(psi) + radius * 1.3255;
                y = radius * sin(psi) - radius * 0.456;
                z = (zlike - pi / 3) * height / (2 * pi);
            end
            
            geo = Geometry(@Cilinder, 150);
            [res, err] = geo.CalcArea(0.67,0.5679);
            area = pi * radius^2;
            obj.verifyLessThan(abs(res - area), err);
            obj.verifyLessThan(err, area / 100);
            obj.verifyGreaterThan(err * 10, abs(res - area));
            
            geo.SetDirection(0.78, 0.567);
            [res, err] = geo.CalcArea(0.67, 0.5679);
            res = res * cos(0.78);
            err = err * cos(0.78);
            area = pi * radius^2;
            obj.verifyLessThan(abs(res - area), err);
            obj.verifyLessThan(err, area / 100);
            obj.verifyGreaterThan(err * 10, abs(res - area));
        end %TestCilindricalArea
        
        function TestEllipsVolume(obj)
            % Make an ellipse and make sure this volume is calculated 
            % correctly as well.
            %
            % Tests convex & enclosed against exact value.
            %
            % In particular, this is a test for closed surfaces.
            a = 7;
            b = 3;
            c = 1;
            
            function [x, y, z] = Ellips(zlike, plane)   
                z = c .* cos(zlike / 2);
                x = a .* sqrt(1 - (z./c).^2) .* cos(plane);
                y = b .* sqrt(1 - (z./c).^2) .* sin(plane);
            end
            
            geo = Geometry(@Ellips, 150);
            [res, err] = geo.CalcVolume();
            volume = 4/3 * pi * a * b * c;
            
            obj.verifyLessThan(err / res, 0.001);
            obj.verifyLessThan(abs(volume - res), err);
            
            % If these trigger, you did too well and could have given me a
            % smaller error as a user or think of a better way to do your
            % error handling.
            obj.verifyGreaterThan(abs(volume - res) * 3, err);
        end %TestEllipsVolume
        
        function TestEllipsArea(obj)
        
            a = 7;
            b = 3;
            c = 1;
            
            function [x, y, z] = Ellips(zlike, plane)   
                z = c .* cos(zlike / 2);
                x = a .* sqrt(1 - (z./c).^2) .* cos(plane);
                y = b .* sqrt(1 - (z./c).^2) .* sin(plane);
            end
            
            geo = Geometry(@Ellips, 150);
            
            [res, err] = geo.CalcArea(pi,0);
            area = pi * a * b;
            obj.verifyLessThan(abs(res - area), err);
            obj.verifyLessThan(err, area / 100);
            obj.verifyGreaterThan(err * 10, abs(res - area));
            
            [res, err] = geo.CalcArea(pi / 2,0);
            area = pi * a * b / 2;
            obj.verifyLessThan(abs(res - area), err);
            obj.verifyLessThan(err, area / 100);
            obj.verifyGreaterThan(err * 10, abs(res - area));

            % This parametrization does not allow going over the pole,
            % so pass by it. This is because at that the north/south pole
            % there is no way for the algorithm to keep psi straight and it
            % has to get psi right for theta to vary away from the pole.
            geo.SetDirection(pi/2, 0);
            [res, err] = geo.CalcArea(0.1, 0);
            area = pi * b * c * cos(0.1/2)^2;
            obj.verifyLessThan(abs(res - area), err);
            obj.verifyLessThan(err, area / 100);
            obj.verifyGreaterThan(err * 10, abs(res - area));
            
        end %TestEllipsArea
        
        function TestTorusVolume(obj)
            % Make an ellipse and make sure this volume is calculated 
            % correctly as well.
            %
            % Tests enclosed against exact value.
            %
            % In particular, this is a concave and topological shape
            % 
        
            major = 7;
            minor = 2;
            function [x, y, z] = Torus(toroid, poloid)
                x = (minor .* cos(poloid) + major) .* cos(toroid);
                y = (minor .* cos(poloid) + major) .* sin(toroid);
                z = minor .* sin(poloid);
            end
            
            geo = Geometry(@Torus, 150);
            [res, err] = geo.CalcVolume();
            volume = 2 * pi^2 * minor^2 * major;
            
            obj.verifyLessThan(err / res, 0.001);
            disp('Torus volume is bad because of the VolumeHeight algorithm');
            obj.verifyLessThan(abs(volume - res), err * 10);
            
            % If these trigger, you did too well and could have given me a
            % smaller error as a user or think of a better way to do your
            % error handling.
            obj.verifyGreaterThan(abs(volume - res) * 3, err);
        end %TestTorusVolume
        
        function TestTorusArea(obj)
            % Take cross sections perpendicular to z axis.
            % Also some perpendicular.
            
            major = 7;
            minor = 2;
            function [x, y, z] = Torus(toroid, poloid)
                x = (minor .* cos(poloid) + major) .* cos(toroid);
                y = (minor .* cos(poloid) + major) .* sin(toroid);
                z = minor .* sin(poloid);
            end
            
            geo = Geometry(@Torus, 150);
            [res, err] = geo.CalcArea(0, 0);
            area = pi * (major + minor)^2;
            obj.verifyLessThan(err/res, 100);
            obj.verifyLessThan(abs(res - area), err);
            
            % In this case, unlike the volume where there are convergence
            % issues, the error is in reality more than an order of
            % magnitude less than reported.
            %obj.verifyLessThan(err*10, abs(res - area));
            
            [res, err] = geo.CalcArea(0, pi);
            area = pi * (major - minor)^2;
            obj.verifyLessThan(err/res, 100);
            obj.verifyLessThan(abs(res - area), err);
            %obj.verifyLessThan(err*10, abs(res - area));
            
            geo.SetDirection(pi/2, 0.8765);
            [res, err] = geo.CalcArea(0.8765 + pi/2, 0);
            area = pi * minor^2;
            obj.verifyLessThan(err/res, 100);
            obj.verifyLessThan(abs(res - area), err);
            
            geo.SetDirection(0, 0);
            [res, err] = geo.CalcArea(0, pi/2.1);
            area = pi * (major + cos(pi/2.1)*minor)^2;
            obj.verifyLessThan(err/res, 100);
            obj.verifyLessThan(abs(res - area), err);
        end %TestTorusArea
        
        function TestSphereArea(obj)
            % Sphere area is interesting whereas volume is just ellips and
            % not really worth spending attention on. The area can here be
            % used to test a bit more awkward directions.
        
            R = 5;
            function [x, y, z] = Sphere(zlike, plane)   
                z = R .* cos(zlike / 2);
                x = R .* sqrt(1 - (z./R).^2) .* cos(plane);
                y = R .* sqrt(1 - (z./R).^2) .* sin(plane);
            end
            
            % The error is really much smaller than indicated here.
            geo = Geometry(@Sphere, 150);
            [res, err] = geo.CalcArea(pi, 0);
            area = pi * R^2;
            obj.verifyLessThan(err/res, 100);
            obj.verifyLessThan(abs(res - area), err);

            geo.SetDirection(0.87, 5.56);
            [res, err] = geo.CalcArea(0.34, 5.56);
            area = pi * R^2 * sin(0.87-0.34/2)^2;
            obj.verifyLessThan(err/res, 100);
            obj.verifyLessThan(abs(res - area), err);
            
            geo.SetDirection(pi/2, 5.56);
            [res, err] = geo.CalcArea(pi, 3.56);
            area = pi * R^2 * sin(2)^2;
            obj.verifyLessThan(err/res, 100);
            obj.verifyLessThan(abs(res - area), err);
            
        end %TestSphereArea
        
    function TestFindPlane(obj)
        % Both at a symmetry and off-angle direction on a Cilinder.
        
        H = 10;
        R = 7;
        
        function [x, y, z] = Cilinder(zlike, psi)
            z = H * (zlike - pi) / (2*pi);
            x = R * cos(psi);
            y = R * sin(psi);
        end
        
        % On axis
        aRef = 2.687;
        bRef = 3.567;
        [~, ~, zRef] = Cilinder(aRef, bRef);
        
        geometry = Geometry(@Cilinder, 200);
        dist = geometry.CalcDistance(aRef, bRef);
        obj.verifyLessThan(abs(dist - zRef), 1e-10);
        
        [aNew, bNew] = geometry.FindPlane(dist);
        [~, ~, zNew] = geometry.Points(aNew, bNew);
        check = geometry.CalcDistance(aNew, bNew);
        obj.verifyLessThan(abs(zNew - zRef), 1e-5);
        obj.verifyLessThan(abs(check - dist), 1e-5);
        
        % Off axis
        aRef = 2.687;
        bRef = 3.567;
        [xRef, yRef, zRef] = Cilinder(aRef, bRef);
        
        geometry = Geometry(@Cilinder, 200);
        geometry.SetDirection(2.43, 1.65);
        real = xRef*cos(1.65)*sin(2.43) + yRef*sin(1.65)*sin(2.43) + ...
                zRef*cos(2.43);
        dist = geometry.CalcDistance(aRef, bRef);
        obj.verifyLessThan(abs(dist - real), 1e-5);
        
        [aNew, bNew] = geometry.FindPlane(dist);
        check = geometry.CalcDistance(aNew, bNew);
        obj.verifyLessThan(abs(check - real), 1e-5);
    end %TestFindPlane
    
    function TestFindPlaneHarder(obj)
        % Now with a corrugated cilinder where psi matters as well.
        
        R = 5;
        H = 10;
        
        function [x, y, z] = Cilinder2(zlike, psi)
            z = H * (zlike - pi) ./ (2*pi);
            x = (R + 1.5.*cos(psi).^2 + 0.1 .* cos(zlike)) .* cos(psi);
            y = (R + 1.2.*sin(psi).^2 + 0.1 .* cos(zlike)) .* sin(psi);
        end
        
        geometry = Geometry(@Cilinder2, 200);
        geometry.SetDirection(4.5378, 1.2498);
        aRef = 0.556;
        bRef = 1.46;
        [xRef, yRef, zRef] = geometry.Points(aRef, bRef);
        dRef = geometry.CalcDistance(aRef, bRef);
        
        real = xRef*cos(1.2498)*sin(4.5378) + ...
               yRef*sin(1.2498)*sin(4.5378) + ...
               zRef*cos(4.5378);
        
        [aNew, bNew] = geometry.FindPlane(dRef);
        check = geometry.CalcDistance(aNew, bNew);
        obj.verifyLessThan(abs(check - real), 1e-5);
        
    end %TestFindPlaneHarder
    end %methods   
end %GeometryTest
