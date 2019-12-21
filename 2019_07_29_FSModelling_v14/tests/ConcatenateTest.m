classdef ConcatenateTest < matlab.unittest.TestCase
% Make sure this properly combines row and column arrays.
    
    methods(Test)
        function testConcatenateCommon(obj)
            % Test a standard case where two finite arrays are joined.
            
            x = (0:1:2);
            y = (0:1:3);
            z = Concatenate({x, y});
            obj.verifyEqual(z, [0, 1, 2, 0, 1, 2, 3]);
        end %testConcatenateCommon
        
        function testConcatenateCorners(obj)
            % Empty arrays are a corner cases, even though they have 
            % no separate branches in the code.
            
            x = (0:1:2);
            y = zeros(0, 1);
            z1 = Concatenate({x, y});
            z2 = Concatenate({y, x});
            obj.verifyEqual(z1, x);
            obj.verifyEqual(z2, x);
            
            a = Concatenate({y, y});
            obj.verifyTrue(isempty(a));
        end %testConcatenateCorners
        
        function testConcatenateExpanded(obj)
            % Give the arguments in the new form: like Concatenate(x, y);
            
            x = (0:1:2);
            y = (0:1:3);
            z = Concatenate(x, y);
            obj.verifyEqual(z, [0, 1, 2, 0, 1, 2, 3]);
        end %testConcatenateExpanded
        
        function testConcatenateCells(obj)
            % An extension was made such that heterogeneous objects become
            % cells, which is tested here.
            
            x = {1, 2, 3};
            s = {'a', 'b', 'c'};
            z = Concatenate(x, s);
            
            expect = {1, 2, 3, 'a', 'b', 'c'};
            obj.verifyEqual(z, expect);
            
        end %testConcatenateCells
        
    end %methods
end %ConcatenateTest
