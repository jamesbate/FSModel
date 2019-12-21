classdef ParabolaTest < matlab.unittest.TestCase
% ParabolaFit extracts the extremum when three points are given by 
% fitting a parabola. ParabolaCurvature returns the curvature at the 
% central point, which corresponds to the second derivative in any 
% extremum.
    
    methods(Test)
        
        function testParabolaSimple(obj)
            % Do a fit to y=x^2 using x=[-1,0,1]. Simplest case.
            x0 = 0;
            dx = 1;
            y1 = (x0 - dx) ^ 2 + 5;
            y2 = x0 ^ 2 + 5;
            y3 = (x0 + dx) ^ 2 + 5;
            max = ParabolaFit(x0, dx, y1, y2, y3);
            obj.verifyLessThan(abs(max), 1e-10);
        end %testParabolaSimple
        
        function testParabolaHard(obj)
            % Fit y=ax^2+bx+c around non-regular x with odd dx

            x0 = 7.3456;
            dx = 2.453;
            xc = 12.156;
            const = -0.677;
            y1 = 6 * (x0 - dx - xc) ^ 2 + const;
            y2 = 6 * (x0 - xc) ^ 2 + const;
            y3 = 6 * (x0 + dx - xc) ^ 2 + const;
            max = ParabolaFit(x0, dx, y1, y2, y3);
            obj.verifyLessThan(abs(max - xc), 1e-10);
        end %testParabolaHard
        
        function testParabolaHardIrr(obj)
            % Now with irregularly spaced x.
            x0 = 5.345;
            x1 = 7.3456;
            x2 = 10.456;
            xc = 12.156;
            const = -0.677;
            y1 = 6 * (x0 - xc) ^ 2 + const;
            y2 = 6 * (x1 - xc) ^ 2 + const;
            y3 = 6 * (x2 - xc) ^ 2 + const;
            max = ParabolaFitIrr(x0, x1, x2, y1, y2, y3);
            obj.verifyLessThan(abs(max - xc), 1e-10);
        end
        
        function testParabolaCurvature(obj)
            % Test that y=ax^2+bx+c in the extremum returns 2a
           
            % In a minimum: positive curvature
            f = @(x) x ^ 2 - 2;
            curve = ParabolaCurvature(0, 1, f(-1), f(0), f(1));
            obj.verifyLessThan(abs(curve - 2), 1e-5);
            
            % In a maximum: negative curvature
            g = @(x) -x ^ 2 + 879;
            curve = ParabolaCurvature(1, 1, g(-1), g(0), g(1));
            obj.verifyLessThan(abs(curve + 2), 1e-5);
            
            % Around maximum with different location
            h = @(x) -2 * x ^ 2 + 4 * x + 879;
            curve = ParabolaCurvature(1, 1, h(0), h(1), h(2));
            obj.verifyLessThan(abs(curve + 4), 1e-5);
            
            % Around maximum with different coefficient
            h = @(x) -pi * x ^ 2 + 14 * x + 879;
            curve = ParabolaCurvature(7/pi, 0.1, h(7/pi-0.1), h(7/pi), h(7/pi+0.1));
            obj.verifyLessThan(abs(curve + 2 * pi), 1e-5);
        end
        
        function testParabolaCurvatureIrr(obj)
            % Test that y=ax^2+bx+c in the extremum returns 2a
            % Now with irregular intervals
           
            % In a minimum: positive curvature
            % Simple symmetric
            f = @(x) x ^ 2 - 2;
            curve = ParabolaCurvatureIrr(-1, 0, 1, f(-1), f(0), f(1));
            obj.verifyLessThan(abs(curve - 2), 1e-5);
            
            % In a maximum: negative curvature
            g = @(x) -x ^ 2 + 879;
            curve = ParabolaCurvatureIrr(-6, 0, pi, g(-6), g(0), g(pi));
            obj.verifyLessThan(abs(curve + 2), 1e-5);
            
            % Around maximum with different location
            h = @(x) -2 * x ^ 2 + 4 * x + 879;
            curve = ParabolaCurvatureIrr(0, 1, 2.3, h(0), h(1), h(2.3));
            obj.verifyLessThan(abs(curve + 4), 1e-5);
            
            % Around maximum with different coefficient
            h = @(x) -pi * x ^ 2 + 14 * x + 879;
            curve = ParabolaCurvatureIrr(1, 7/pi, 4, h(1), h(7/pi), h(4));
            obj.verifyLessThan(abs(curve + 2 * pi), 1e-5);
            
            % Switching the interval to reverse does not matter at all.
            h = @(x) -pi * x ^ 2 + 14 * x + 879;
            curve = ParabolaCurvatureIrr(4, 7/pi, 1, h(4), h(7/pi), h(1));
            obj.verifyLessThan(abs(curve + 2 * pi), 1e-5);
        end
    end %methods
end %ParabolaFitTest