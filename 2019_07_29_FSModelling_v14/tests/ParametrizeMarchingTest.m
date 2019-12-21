classdef ParametrizeMarchingTest < matlab.unittest.TestCase
% Test the Marching Square algorithm.
%
% This function is critical to find orbits as it can take a 2D
% function with scalar result and follow constant function values.
% This is used to follow a plane perpendicular to B,
% the constant value is the distance to the plane perpendicular to B and
% through the origin. 
% However the function is made for general z = f(x, y) constant-z orbits.
% That is tested here for various types of functions.
%
% Tests good / common cases, not codepath/corner case complete.
    
    methods  (Test)
        
    function testMarching(obj)
        % Follow a circle.
        
        count = 0;
        function z = followme(x, y)
            z = sqrt(x .^ 2 + y .^ 2);
            count = count + 1;
        end
        
        % Take a second to realize how confined this is.
        % Followme returns the radius. The radius with minimum stepsize 
        % 0.025 using just 4 evaluations does not deviate more than 0.02%
        % over the entire path.
        path = MarchingSquare(@followme, 3, 4, 0.05, 0.05, 10000, true);
        obj.verifyEqual(count, length(path));
        obj.verifyTrue(all( abs(followme(path(:,1), path(:,2)) - 5) < 0.0001 ));
        obj.verifyLessThan(length(path), 1500);
    end %testMarching
    
    function testMarching2(obj)
        % Follow a quite complicated shape.
        
        count = 0;
        function z = followme(x, y)
            z = 7000 + 5 * sqrt(x .^ 4 + 7 * y .^ 2);
            count = count + 1;
        end
        
        % Again, take a second to realize how precise this is.
        path = MarchingSquare(@followme, 3, 4, 0.05, 0.05, 10000, true);
        obj.verifyEqual(count, length(path));
        z0 = followme(3, 4);
        dev = abs(followme(path(:,1), path(:,2)) - z0);
        obj.verifyTrue(all(dev < 0.01));
        obj.verifyLessThan(length(path), 1500);
        obj.verifyGreaterThan(length(path), 150);
    end %testMarching2
    
    function testMarching3(obj)
        % Follow a straight line in north/south direction
        
        count = 0;
        function z = followme(x, y)
            z = 7000 + 5 * sqrt(x .^ 4);
            count = count + 1;
        end
        
        % Again, take a second to realize how precise this is.
        path = MarchingSquare(@followme, 3, 4, 0.05, 0.05, 10000, true, [0, 10]);
        obj.verifyEqual(count, length(path));
        z0 = followme(3, 4);
        dev = abs(followme(path(:,1), path(:,2)) - z0);
        obj.verifyTrue(all(dev < 0.01));
        obj.verifyLessThan(length(path), 1500);
        obj.verifyGreaterThan(length(path), 150);
    end %testMarching3
    
    function testMarching4(obj)
        % Follow a straight line in east/west direction
        
        count = 0;
        function z = followme(x, y)
            z = 7000 + 5 * sqrt(y .^ 4);
            count = count + 1;
        end
        
        % Again, take a second to realize how precise this is.
        path = MarchingSquare(@followme, 3, 4, 0.05, 0.05, 10000, true, [10, 0]);
        obj.verifyEqual(count, length(path));
        z0 = followme(3, 4);
        dev = abs(followme(path(:,1), path(:,2)) - z0);
        obj.verifyTrue(all(dev < 0.01));
        obj.verifyLessThan(length(path), 1500);
        obj.verifyGreaterThan(length(path), 150);
    end %testMarching4
    
    function testMarching5(obj)
        % Follow a diagonal northwest/southeast line.
        
        count = 0;
        function z = followme(x, y)
            d = mod(x-y, 10);
            z = 7000 + 5 * d.^2;
            count = count + 1;
        end
        
        path = MarchingSquare(@followme, 3, 4, 0.05, 0.05, 10000, true, [10, 10]);
        obj.verifyEqual(count, length(path));
        z0 = followme(3, 4);
        dev = abs(followme(path(:,1), path(:,2)) - z0);
        obj.verifyTrue(all(dev < 0.01));
        obj.verifyLessThan(length(path), 1500);
        obj.verifyGreaterThan(length(path), 150);
    end %testMarching5
    
    end %method
end %MarchingSquareAndAreaTest
