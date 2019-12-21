classdef ExtremeWalkIntervalTest < matlab.unittest.TestCase
% Make sure min/max are properly found

    methods(TestMethodSetup)
        function addSettingsToPath(~)
            AddModule('algorithms');
        end
    end %methods


    methods(Test)
        function testMinimizationWalk(obj)
            % Find the minimum of a parabola
            % Find the boundary maximum
            
            function y = f(x)
                y = (x - 3.456) ^2;
            end %f
            
            extr = ExtremizeWalk(@f, 0, 5, f(-5), f(0), f(5));
            obj.verifyEqual(length(extr), 2);
            obj.verifyLessThan(abs(extr(2) - f(extr(1))), 1e-10);
            obj.verifyLessThan(abs(extr(1) - 3.456), 1e-7);
            
        end %testMinimizationWalk
        
        
        function testMaximizationWalk(obj)
           % Find the max and min of a sine period
            
            function y = f(x)
                y = sin(x);
            end %f
            
            extr = ExtremizeWalk(@f, 4.5, 0.5, f(4), f(4.5), f(5));
            obj.verifyEqual(length(extr), 2);
            obj.verifyLessThan(abs(extr(2) - f(extr(1))), 1e-10);
            obj.verifyLessThan(abs(extr(1) - 3 * pi / 2), 1e-7);
            
            extr = ExtremizeWalk(@f, 1.5, 1.5, f(0), f(1.5), f(3));
            obj.verifyEqual(length(extr), 2);
            obj.verifyLessThan(abs(extr(2) - f(extr(1))), 1e-10);
            obj.verifyLessThan(abs(extr(1) - pi / 2), 1e-7);
        end %testMinimizationWalk
        
        
        function testExtremizeInterval(obj)
            
            function y = testfunc(x)
                y = sin(x);
            end %testfunc
            
            optima = ExtremizeInterval(@testfunc, 0.5 * pi, 4.5 * pi);
            obj.verifyEqual(numel(optima), 10);
                        
            % x values
            obj.verifyLessThan(abs(optima(1, 1) - pi/2), 1e-7);
            obj.verifyLessThan(abs(optima(2, 1) - 3 * pi/2), 1e-7);
            obj.verifyLessThan(abs(optima(3, 1) - 5 * pi/2), 1e-7);
            obj.verifyLessThan(abs(optima(4, 1) - 7 * pi/2), 1e-7); 
            obj.verifyLessThan(abs(optima(5, 1) - 9 * pi/2), 1e-7); 
            
            % y values
            obj.verifyLessThan(abs(optima(1, 2) - 1), 1e-7);
            obj.verifyLessThan(abs(optima(2, 2) + 1), 1e-7);
            obj.verifyLessThan(abs(optima(3, 2) - 1), 1e-7);
            obj.verifyLessThan(abs(optima(4, 2) + 1), 1e-7); 
            obj.verifyLessThan(abs(optima(5, 2) - 1), 1e-7); 
            
            % boundary sensitivity
            optima2 = ExtremizeInterval(@testfunc, 0.56 * pi, 4.44 * pi);
            obj.verifyEqual(numel(optima2), 6);            
            
        end %testExtremizeInterval
        
    end %methods
end %ExtremeWalkTest
