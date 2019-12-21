classdef ComputationalGeometryTest < matlab.unittest.TestCase
% Make various geometries and find their extremal orbits and coverage.

methods (Test)
    function ExtremalCylinderTest(obj)
        % Make a Cylinder and find the extremal orbits.
        % Corner case, all areas are equal and just 1 has to be found.
        
        R = 5;
        h = 7;
        
        function [x, y, z] = Cylinder(zlike, phi)
            x = R .* cos(phi);
            y = R .* sin(phi);
            z = (zlike - pi) ./ (2*pi) .* h;
        end
        
        % Along axis
        geo = Geometry(@Cylinder, 150);
        cg = ComputationalGeometry(geo);
        results = cg.ExtremalAreas();
        obj.verifyEqual(length(results), 1);
        VerifyResult(results, pi * R^2);
        
        % Off axis
        geo.SetDirection(2.55, 2.06);
        cg = ComputationalGeometry(geo);
        results = cg.ExtremalAreas();
        obj.verifyEqual(length(results), 1);
        VerifyResult(results, pi * R^2/abs(cos(2.55)));
    end %ExtremalCylinderTest
    
    function ExtremalSphereTest(obj)
       % A simple test for spheres
       % This also differs from the Cylinder in that 
       % there is no crossover to the next zone and that the numbers are of
       % a completely different order of magnitude, testing also the scale
       % invariance of the convergence.
       % Finally, it tests that a parametrization that returns to its
       % starting point in the first argument is picked up correctly.
       
        R = 5e7;
       
        function [x, y, z] = Sphere(theta, phi)
            x = R .* cos(phi) .* sin(theta/2);
            y = R .* sin(phi) .* sin(theta/2);
            z = R .* cos(theta/2);
        end
        
        geo = Geometry(@Sphere, 150);
        cg = ComputationalGeometry(geo);
            
        results = cg.ExtremalAreas();        
        
        VerifyResult(results, pi * R^2);
        obj.verifyEqual(length(results), 1);
        
        geo.SetDirection(5.43, 1.56);
        cg = ComputationalGeometry(geo);
        results = cg.ExtremalAreas();
        VerifyResult(results, pi * R^2);
        obj.verifyEqual(length(results), 1);
        
    end %ExtremalSphereTest
      
    function TestDiscontinuityExtremals(obj)
        % This is a hard test, but a common one for corrugated Cylinders.
        % As the polar angle approaches 90 degrees, there are
        % discontinuities as the plane is shifted along the field direction
        % in the areas. This provides major challenges.
        %
        % Some reasons:
        %  - Following the area down/up for min/max may lead to a jump
        %   rather than actual extremum.
        %  - Two close discontinuities can hide an extremum 
        %  - Extrema may be pinched between very close discontinuities
        %   at angles where the gap just opens to see the extremum
        %  - You may lose track of a minimum by detecting a fall downwards.
        %   Similar for maxima. This is a stepsize issue.
        %  - The total function variance no longer is an indication of
        %  anything
        %  - There are invariably area=0 orbits.
        %  - At the discontinuity MarchingSquare is unstable due to 
        %   the saddle point. In reality it is infinitessimal, but the 
        %   precision stepsize makes it possible to actually end up there.
        % 
        % The hardest of all:
        %   - Any plane constant refers to 2 planes rather than 1,
        %   making it an ambiguous measure.
        %
        % This is truly a terrible thing and extremly hard to wrap your
        % head around let alone solve.
        
        R = 7;
        dR = 4;
        h = 10;
        
        function [x,y,z] = SomeCylinder(zlike, phi)
            x = (R + dR .* cos(zlike)) .* cos(phi);
            y = (R+ dR .* cos(zlike)) .* sin(phi);
            z = h * (zlike - pi) ./ (2*pi);
        end
        
        % First test along the z direction, this tests 
        % the optimizer for boundaries.
        geo = Geometry(@SomeCylinder, 200);
        cg = ComputationalGeometry(geo);
        results = cg.ExtremalAreas();        
        VerifyResult(results, [pi*(R-dR)^2, pi*(R+dR)^2]);
        obj.verifyEqual(length(results), 2);
        
        global DETAILED;
        if ~isempty(DETAILED) && ~DETAILED
            return;
        end
        
        % Next go to skipping orbits
        % There are some EXTREMLY hard angles possible here.
        % Pictures are in the archive.
        %
        % This is memory based.
        % Determined with precision 1000 and uncertainties are
        % Angle 63/180*pi, 0.56 <a bit easier>
        % 364.5708, 273.4631, 262.9179
        % 1.7e-3, 2.7e-4, 5.2e-4
        %
        % Angle 60.1/180*pi, 0.56
        % 273.9875, 349.8337
        % 3.7e-4, 2.2e-3
        %
        
        cg.SetDirection(63/180*pi, 0.56);
        cg.ShowCover(200);
        results = cg.ExtremalAreas();     
        VerifyResult(results, [364.5708, 273.4631, 262.9179]);
        obj.verifyEqual(length(results), 3);
    end
    
    function NodalTest(obj)
       % Test NodalPoints and NodalCycle at extreme angles in a 
       % 4-nodes double-corrugated Cylinder.
        
        R = 7;
        dR = 4;
        h = 10;
        distort = 0;
        
        function [x,y,z] = ZCorrCylinder(zlike, phi)
            % Defines a surface        
            radius = (R + dR .* cos(zlike)+ dR/3 .* cos(zlike*2));
            radius = radius .* (1 + distort.*cos(2*phi));
            x = radius .* cos(phi);
            y = radius .* sin(phi);
            z = h * (zlike - pi) ./ (2*pi);
        end %ZCorrCylinder
        
       
       % Visualize the surface if you wish.
       if false
           A = (0:2*pi/100:2*pi);
           B = (0:2*pi/100:2*pi);
           [AA, BB] = meshgrid(A, B);
           [XX, YY, ZZ] = ZCorrCylinder(AA, BB);
           figure;
           surf(XX, YY, ZZ);
           xlabel('x');
           ylabel('y');
           zlabel('z');
       end
        
        geometry = Geometry(@ZCorrCylinder, 200);
        cg = ComputationalGeometry(geometry);
        polar = 85;
        azu = 0;
        
        % First test NodalPoints: points where area=0 occurs.
        cg.SetDirection(0, 0);
        [extrA, extrB] = cg.Nodes();
        obj.verifyTrue(isempty(extrA));
        obj.verifyTrue(isempty(extrB));
        
        cg.SetDirection(5/180*pi, 0);
        [extrA, extrB] = cg.Nodes();
        obj.verifyTrue(isempty(extrA));
        obj.verifyTrue(isempty(extrB));
        
        cg.SetDirection(polar/180*pi, azu);
        geometry.maxPathLength = floor(10000 / abs(cos(polar/180*pi)));
        [extrA, extrB] = cg.Nodes();
        realA = [0.0146, 6.2683, 3.0345, 3.2487];
        realB = [2*pi, pi, pi, 2*pi];
        
        obj.verifyEqual(length(extrA), 4);
        obj.verifyLessThan(max(abs(extrA - realA)), 0.001);
        obj.verifyLessThan(max(abs(extrB - realB)), 0.001);        
        
    end %NodalTest
            
    function VolumeTestSphere(obj)
        % Test that the result of Cover can be used to very accurately
        % calculate the volume as ultimate verification that all the 
        % unique orbits are made once and once only.
        
        global DETAILED;
        if ~isempty(DETAILED) && ~DETAILED
            return;
        end
        
        radius = 3;
        function [x,y,z] = Sphere(a,b)
            x = radius .* cos(b) .* sin(a./2);
            y = radius .* sin(b) .* sin(a./2);
            z = radius .* cos(a./2);
        end
        
        
        geo = Geometry(@Sphere, 150);
        cg = ComputationalGeometry(geo);
        cg.SetDirection(2,1);
        [aa,bb] = cg.Cover(150);
        
        areas = zeros(1,length(aa));
        dd = cg.CalcDistance(aa, bb);
        for ind = 1:length(dd)
            areas(ind) = cg.CalcArea(aa(ind),bb(ind));
        end
        
        volume = 0;
        for ind = 1:length(aa)-1
            delta = dd(ind+1) - dd(ind);
            areaAvg = 0.5 * (areas(ind+1)+areas(ind));
            if ~isnan(delta) && ~isnan(areaAvg)
                volume = volume + delta * areaAvg;
            end
        end
        
        v = 4/3*pi*radius^3;
        obj.verifyLessThan(abs(volume - v), v/100);
        
    end %VolumeTestSphere
     
    function VolumeTestCylinder(obj)
        % Test that the result of Cover can be used to very accurately
        % calculate the volume as ultimate verification that all the 
        % unique orbits are made once and once only.
        %
        % Reverses the order of the parameters such that b axis is open
        % as test for the in v1.4 added functionality that the parameter
        % order is arbitrary.
        
        global DETAILED;
        if ~isempty(DETAILED) && ~DETAILED
            return;
        end
        
        radius = 3;
        height = 5;
        function [x,y,z] = Cylinder(a,b)
            x = radius .* cos(a);
            y = radius .* sin(a);
            z = (b-pi)/(2*pi) * height;
        end
        
        geo = Geometry(@Cylinder, 150);
        cg = ComputationalGeometry(geo);
        cg.SetDirection(2,1);
        [aa,bb] = cg.Cover(150);
        
        volume = 0;
        dd = cg.CalcDistance(aa, bb);
        for ind = 1:length(aa)-1
            if isnan(aa(ind)) 
                continue;
            end
            
            delta = dd(ind+1) - dd(ind);
            if ~isnan(delta)
                area = cg.CalcArea(aa(ind),bb(ind));
                volume = volume + delta * area;
            end
        end
        
        v = pi*radius^2*height;
        obj.verifyLessThan(abs(volume - v), v/1000);
        
    end %VolumeTestCylinder
    
    function VolumeTestHardCylinder(obj)
       % Now take a corrugated cilinder with many pockets and verify its 
       % volume against angular invariance and memory.

       global DETAILED;
       global SHOW_COVERAGE;
       if ~isempty(DETAILED) && ~DETAILED
           return;
       end
       
       h = 5;
       R = 7;
       dR = 4;
       distort = 0.3;
       
        function [x,y,z] = ZCorrCylinder(zlike, phi)
            % Defines a surface        
            radius = (R + dR .* cos(zlike)+ dR/3 .* cos(zlike*2));
            radius = radius .* (1 + distort.*cos(2*phi));
            x = radius .* cos(phi);
            y = radius .* sin(phi);
            z = h * (zlike - pi) ./ (2*pi);
        end %ZCorrCylinder
        
        % Compute
        geo = Geometry(@ZCorrCylinder, 150);
        cg = ComputationalGeometry(geo);
        cg.SetDirection(80/180*pi,pi/2);   
        [aa,bb] = cg.Cover(200);
          
        % Prepare cross sectional areas
        dd = cg.CalcDistance(aa, bb);
        areas = zeros(1,length(dd));
        for ind = 1:length(areas)
            try
                areas(ind) = cg.CalcArea(aa(ind),bb(ind));
            catch
            end
        end
        
        % Integrate
        volume = 0;
        for ind = 1:length(aa)-1
            delta = dd(ind+1) - dd(ind);
            areaAvg = 0.5 * (areas(ind+1)+areas(ind));
            if ~isnan(delta) && ~isnan(areaAvg)
                volume = volume + delta * areaAvg;
            end
        end
        
        
        if isempty(SHOW_COVERAGE) || SHOW_COVERAGE
            cg.ShowCover(300);
            figure;
            scatter(dd, areas);
            xlabel('distance');
            ylabel('area');
            title(sprintf('Volume %.3f, real is %.3f', volume, 950.2086));
        
            obj.verifyLessThan(abs(volume-950.2086), 950/50);
            
            [aa,bb] = cg.Cover(300);
            colors = winter(length(aa));
            figure;
            for ind = 1:length(aa)
                try
                    p = cg.CalcPath(aa(ind),bb(ind), true);
                catch
                    continue;
                end
                p(end+1,:) = p(1,:);

                p = mod(p, 2*pi);
                hold on;
                scatter(p(:,1),p(:,2),3,colors(ind,:));
            end
        end
        
    end %VolumeTestHardCylinder
        
    function VolumeTestTorus(obj)
        % Test that the result of Cover can be used to very accurately
        % calculate the volume as ultimate verification that all the 
        % unique orbits are made once and once only.
              
       global DETAILED;
       if ~isempty(DETAILED) && ~DETAILED
           return;
       end
       
        major = 7;
        minor = 2;
        function [x, y, z] = Torus(toroid, poloid)
            x = (minor .* cos(poloid) + major) .* cos(toroid);
            y = (minor .* cos(poloid) + major) .* sin(toroid);
            z = minor .* sin(poloid);
        end
        
        g = Geometry(@Torus, 200);
        cg = ComputationalGeometry(g);
        cg.SetDirection(90/180*pi,0);
        [aa,bb] = cg.Cover(200);
        
        dd = cg.CalcDistance(aa, bb);
        areas = zeros(1,length(dd));
        for ind = 1:length(areas)
            areas(ind) = cg.CalcArea(aa(ind),bb(ind));
        end

        % Integrate
        volume = 0;
        for ind = 1:length(aa)-1
            delta = dd(ind+1) - dd(ind);
            areaAvg = 0.5 * (areas(ind+1)+areas(ind));
            if ~isnan(delta) && ~isnan(areaAvg)
                volume = volume + delta * areaAvg;
            end
        end
        
        cg.ShowCover(200);
        v = 2*pi^2*minor^2*major;
        obj.verifyLessThan(abs(v-volume), v/100);
        end %VolumeTestTorus
                
    function VolumeTestTorus2(obj)
        % Test that the result of Cover can be used to very accurately
        % calculate the volume as ultimate verification that all the 
        % unique orbits are made once and once only.
        %
        % This time with the direction almost along z.
              
       global DETAILED;
       if ~isempty(DETAILED) && ~DETAILED
           return;
       end
       
        major = 7;
        minor = 1;
        function [x, y, z] = Torus(toroid, poloid)
            x = (minor .* cos(poloid) + major) .* cos(toroid);
            y = (minor .* cos(poloid) + major) .* sin(toroid);
            z = minor .* sin(poloid);
        end
        
        g = Geometry(@Torus, 200);
        cg = ComputationalGeometry(g);
        cg.SetDirection(5/180*pi,0);
        
        [aa,bb] = cg.Cover(200);
        dd = cg.CalcDistance(aa, bb);
        areas = zeros(1,length(dd));
        for ind = 1:length(areas)
            areas(ind) = cg.CalcArea(aa(ind),bb(ind));
        end
        
        % Integrate
        volume = 0;
        for ind = 1:length(aa)-1
            delta = dd(ind+1) - dd(ind);
            areaAvg = 0.5 * (areas(ind+1)+areas(ind));
            if ~isnan(delta) && ~isnan(areaAvg)
                volume = volume + delta * areaAvg;
            end
        end
        
        %v = 2*pi^2*minor^2*major;
        % The real volume will not be found here
        % The empty space in the middle is all added up instead of 
        % cancelled out because you make large wrapping orbits.
        % 
        % That is why minor is chosen so small here, such that this 
        % is basically all the same circles and the obtained value can be
        % verified, even though it is weird it is predictable.
        cg.ShowCover(200);
        v = 2*pi*major^2;
        obj.verifyLessThan(abs(v-volume), v/10);
        
        end %VolumeTestTorus
end %methods
end %ExtremalAreaGeometryTest




function VerifyResult(results, reals)
    % Make sure the result is accurate, correct and has a decent
    % indication of the error made if provided at all.
    % 
    % Result is a cell array of one or more results
    % reals is a double or array of possible areas.
    % They do NOT have to match length.
    % 
    % Checks that all results are among reals
    % Checks that all results are different reals.
    %
    % !! Check separately that the number of results is as expected.
    %
    % This is separate because it seemed to not trigger when I made
    % it a non-test method in the unittest class.
    
    seen = ones(1, length(reals)) == 0;
    for ind = 1:length(results)
        res = results{ind};
        [~, index] = min(abs(reals - res.area));
        if seen(index)
            disp(results{ind});
            error('Above result is duplicated'); 
        end

        seen(index) = true;
        real = reals(index);

        if ~res.converged
            disp(results{ind});
            error('Above result is not converged');
        end
        
        if abs(res.area - real) > real*1e-2
            disp(results{ind});
            error('Above result is too far off: %.3e, max off is %.3e', ...
                  abs(res.area - real), real*1e-2);
        end
        if res.dArea > 0 && abs(res.area - real) > res.dArea * 1.5
            disp(results{ind});
            error('Above result has an area offset %.3e, does not match dArea',...
                  abs(res.area - real));
        end
    end

end %VerifyResult
