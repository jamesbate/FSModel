% Version 1.0 25 May 2019
%   Make this test, even though the function exists for a couple days
%   it was untested and now it is breaking when moving from 
%   matlab 2018b to 2016a
%

classdef SignatureArgsTest < matlab.unittest.TestCase
    methods (Test)
        function TestInputArgs(obj)
           % Test this method onto inputargsfunction 
            
            test = @SignatureArgsFunction;
            old = cd('..\bin\calculations\symmetries\private');
            try
                obj.verifyEqual(nargin(test), 8);
                args = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'hahahahahaa'};
                obj.verifyEqual(length(args), nargin(test));
                result = Signature(test);
                obj.verifyEqual(result, args);
            catch err
                cd(old);    
                rethrow(err);
            end
            cd(old);
        end %TestInputArgs
    end %methods
end %InputArgsTest
    