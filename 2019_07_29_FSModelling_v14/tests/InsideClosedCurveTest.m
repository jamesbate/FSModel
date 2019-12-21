classdef InsideClosedCurveTest < matlab.unittest.TestCase
   
    methods (Test)
       
        function TestInsideClosedCurve(obj)
            % Test the 'is this point inside my orbit' test with 
            % both a trivial circle and a multiple-rotation circle.
            
            for rotation = (1:5:6)
                phi = (0:2*pi/100:2*pi*rotation);
                xx = cos(phi);
                yy = sin(phi);
                obj.verifyTrue(InsideClosedCurve(xx, yy, 0,0));
                obj.verifyTrue(InsideClosedCurve(xx, yy, 0.5,0.5));
                obj.verifyFalse(InsideClosedCurve(xx, yy, 1,-1));
                obj.verifyFalse(InsideClosedCurve(xx, yy, -2,0));
                obj.verifyFalse(InsideClosedCurve(xx, yy, 0,2)); 

                obj.verifyTrue(InsideClosedCurve(xx, yy, 0.99, 0));
                obj.verifyTrue(InsideClosedCurve(xx, yy, 0, 0.99));
            end            
                        
            % And a test with a hard case
            % Hard because it needs to jump >pi/2 at once
            % which is not doable with a normal arctan.
            xx = [0, 0, 1];
            yy = [0, 1, 0];
            obj.verifyTrue(InsideClosedCurve(xx, yy, 0.45, 0.45));
            obj.verifyFalse(InsideClosedCurve(xx, yy, 0.55, 0.55));
            
        end %TestInsideClosedCurve
        
    end 
end