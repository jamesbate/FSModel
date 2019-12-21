classdef DescendTest < matlab.unittest.TestCase
%Test the gradient descend algorithm for minima and maxima.
    
    methods (Test)
        function ParabolicMinimum(obj)
            
            function v = parabola(x, y)
                v = (x-3).^2 + (y-1).^2;
            end
            
            % Go for value convergence to 
            [x, y, v] = MarchingDescend2(@parabola, 0, 0, 10, 10, true, ...
                                        0, 0, 1e-8);
            [x2, y2, v2] = WalkingDescend2(@parabola, 0, 0, 10, 10, true, 100000);

            obj.assertLessThan(abs(v), 1e-8);
            obj.assertLessThan(abs(x - 3), 1e-4);
            obj.assertLessThan(abs(y - 1), 1e-4);
            obj.assertLessThan(abs(v2), 1e-8);
            obj.assertLessThan(abs(x2 - 3), 1e-4);
            obj.assertLessThan(abs(y2 - 1), 1e-4);
            obj.assertGreaterThan(abs(y2-1), 1e-5);
            obj.assertGreaterThan(abs(x2-1), 1e-5);
            
            % Go for postional convergence.
            [x, y, v] = MarchingDescend2(@parabola, 0, 0, 10, 10, true, ...
                                        1e-7, 1e-7, -1);
            obj.assertLessThan(abs(v), 1e-13);
            obj.assertLessThan(abs(x - 3), 1e-7);
            obj.assertLessThan(abs(y - 1), 1e-7);
            
            % Same for maximum should diverge
            try
               MarchingDescend2(@parabola, 0, 0, 10, 10, false, ...
                                        1e-7, 1e-7, -1);
               error('MarchingDescend2 should have failed to find max');
            catch exc
                if ~strcmp(exc.identifier, 'Descend:max_evals')
                    rethrow(exc);
                end
            end %try            
            
            
            try
                WalkingDescend2(@parabola, 0, 0, 10, 10, false, 100000);
                error('MarchingDescend2 should have failed to find max');
            catch exc
                if ~strcmp(exc.identifier, 'Descend:max_evals')
                    rethrow(exc);
                end
            end %try            
        end %ParabolicMinimum
        
        function SpecialWalksTest(obj)
            % Walking does converge if you put no boundary on it
            % and search for a maximum in a parabola with positive curve.
            % However with boundaries interesting limiting cases happen.
            % They are tested here.
            
            function v = parabola(x, y)
                v = (x-3).^2 + (y-1).^2;
            end
            
            % This is quite a demand at once, it requires 
            % first walking to the boundary and then to walk alongside
            % the boundary to get to the corner where the parabola
            % is largest. Overshot has to be used to round the values to
            % get an exact match, the convergence criterion is not accurate
            % enough to satisfy the test!
            [x, y, ~] = WalkingDescend2(@parabola, 0, 0, 12.1, 13.3, false, 100, ...
                                       0, 1000, 0, 500, false);
            obj.verifyLessThan(abs(x-1000), 1e-5);
            obj.verifyLessThan(abs(y-500), 1e-5);
            
            % Repeat, but this time make it even harder by setting the
            % boundary to modulo, the boundary is discontinuous here.
            [x, y, ~] = WalkingDescend2(@parabola, 0, 1, pi, 3*pi, false, 10000, ...
                                       0, 600.1, 0, 500.1, true);
            obj.verifyLessThan(abs(x-600.1), pi/10000);
            obj.verifyLessThan(abs(y-500.1), 3*pi/10000);
        end %SpecialWalkTest
        
        function ParabolicMaximum(obj)
            % Really does not need to test much more here.
            % To be codepath complete, just need to go through it once.
            
            function v = parabola(x, y)
                v = - x^2 - 3 * y^2;
            end
        
            [x, y, v] = MarchingDescend2(@parabola, 0, 0, 10, 10, false);
            obj.assertLessThan(abs(v), 1e-7);
            obj.assertLessThan(abs(x), 1e-4);
            obj.assertLessThan(abs(y), 1e-4);
            
            try
               MarchingDescend2(@parabola, 0, 0, 10, 10, true);
               error('MarchingDescend2 should have failed to find min');
            catch exc
                if ~strcmp(exc.identifier, 'Descend:max_evals')
                    rethrow(exc);
                end
            end %try            
        end %ParabolicMaximum
        
        
        function LocalExtremum(obj)
           % Find the minima and maxima of a double-sine.
            
            function v = sinusoid(x, y)
                v = sin(x) * sin(y);
            end
            
            % Initially a step along y does not matter
            % A step along x indicates moving to negative x.
            % Then sin(x) is negative and sin(y) should be maximally
            % positive which means stepping towards y=pi/2, x=-pi/2.
            [x, y, v] = MarchingDescend2(@sinusoid, 0, 1, 0.1, 0.1, true);
            obj.assertLessThan(abs(v+1), 1e-7);
            obj.assertLessThan(abs(x + pi/2), 1e-4);
            obj.assertLessThan(abs(y - pi/2), 1e-4);
            
            % Initially a step along y does not matter
            % A step along x indicates moving to positive x
            % Then maximizing both sines positively ends at pi/2 for both.
            [x, y, v] = MarchingDescend2(@sinusoid, 0, 1, -0.1, 0.1, false);
            obj.assertLessThan(abs(v - 1), 1e-7);
            obj.assertLessThan(abs(y - pi/2), 1e-4);
            obj.assertLessThan(abs(x - pi/2), 1e-4);
            
            % Repeat the first one with x & y switched.
            [x, y, v] = MarchingDescend2(@sinusoid, 1, 0, 0.1, 0.1, true);
            obj.assertLessThan(abs(v+1), 1e-7);
            obj.assertLessThan(abs(x - pi/2), 1e-4);
            obj.assertLessThan(abs(y + pi/2), 1e-4);
            
            % Repeat the second one with x and y switched
            [x, y, v] = MarchingDescend2(@sinusoid, 1, 0, 0.1, 0.1, false);
            obj.assertLessThan(abs(v - 1), 1e-7);
            obj.assertLessThan(abs(y - pi/2), 1e-4);
            obj.assertLessThan(abs(x - pi/2), 1e-4);
        end %LocalExtremum

        function TestDescend1D(obj)
            % The 1D version was created later because it turned out
            % useful. If ever a 3D one is necessary it may be worthwhile to
            % make a generalized one for any dimension. It is a significant
            % larger hussle though regarding readability, abstraction
            % itself is not that bad but guaranteeing it is always right is
            % not fun and dimensionality scaling is terrible now as well
            % because some things are quadratic whereas other aspects are
            % linear in the dimension.
            
            extr = WalkingDescend1(@sin, -0.4, 0.1, true, 1/10000);
            obj.verifyLessThan(abs(extr+pi/2), 1/10000);
            
            extr = WalkingDescend1(@sin, -0.4, 0.1, false, 1/10000);
            obj.verifyLessThan(abs(extr-pi/2), 1/10000);
            
            extr = WalkingDescend1(@sin, -0.4, 0.1, true, 0, 1/10000);
            obj.verifyLessThan(abs(sin(extr)+1), 1/10000);
            
            extr = WalkingDescend1(@sin, -0.4, 0.1, false, 0, 1/10000);
            obj.verifyLessThan(abs(sin(extr)-1), 1/10000);
        end
    
    end %methods
end %ExtremumMarchingAndDescend
