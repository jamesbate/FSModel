classdef NewtonRaphsonTest < matlab.unittest.TestCase
    
    methods (Test)
        function TestLinear1D(obj)
            % Test a linear function in 1D, 1 step exact solution.            

            function y = f(x)
                y = x;
            end

            res = NewtonRaphson(@f, 3, 1, 1e-5, 0, 1e-5);
            obj.verifyEqual(length(res), 1);
            obj.verifyLessThan(abs(f(res) - 3), 1e-5);
        end %TestLinear1D

        function TestLinear2D(obj)
            % Test a linear function in 2D, 1 step exact solution.            

            function y = f(x)
                y = x(1) + x(2);
            end

            res = NewtonRaphson(@f, 3, [1,1], 1e-5, 0, 1e-5);
            obj.verifyEqual(length(res), 2);
            obj.verifyLessThan(abs(f(res) - 3), 1e-5);
        end %TestLinear2D

        function TestNonlinear1D(obj)
            % Test a non-linear 1D function

            function y = g(x)
                y = sqrt(x) - 1.34;
            end

            res = NewtonRaphson(@g, 3, 1, 1e-7, 0, 1e-5);
            obj.verifyLessThan(abs(g(res)-3), 1e-5);
        end %TestNonlinear1D

        
        function TestNonlinear2D(obj)
            % Test a non-linear 2D function

            function y = g(x)
                y = x(1).^2 + x(2).^3;
            end

            res = NewtonRaphson(@g, -3, [1,-1], 1e-8, 0, 1e-5);
            obj.verifyLessThan(abs(g(res)+3), 1e-5);
        end %TestNonlinear2D
        
    end %methods
end %NewtonRaphsonTest
