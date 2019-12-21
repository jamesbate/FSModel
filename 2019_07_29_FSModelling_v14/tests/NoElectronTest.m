classdef NoElectronTest < matlab.unittest.TestCase
% Test this function against memorized values.

    methods(Test)
        
        function testMemoryFeSe(obj)
            % This case was verified on the old program
            % and is has to still hold
            
            band = containers.Map;
            band('symmetry') = 'FeSeTetragonal';
            band('a') = 3;
            band('b') = 3;
            band('c') = 5;
            band('kcoeff') = [0.3, 0.01, 0.02, 0, 0.04, 0, 0];
            band('type') = 'hole';
            band('precision') = 200;
            n = FillingFraction(band);
            
            % Note the following:
            % 1) It is known that the old one forgets to divide by 8pi^3
            % but other than that it should correspond.
            % 2) Also it is known that the k12 (4th parameter)
            % is wrongly implemented, but it is set to 0 here.
            old = 16.1042 / (8 * pi^3);
            obj.verifyLessThan(abs(old - n), old / 100);
        end %testMemory
        
        function testMemoryTetragonal(obj)
            % This case was verified on the old program
            % and is has to still hold          
            
            global detailed;
            if ~isempty(detailed) && ~detailed
                return;
            end
            
            band = containers.Map;
            band('symmetry') = 'Tetragonal';
            band('a') = 4;
            band('b') = 4;
            band('c') = 20;
            band('kcoeff') = [0, -0.02, 0.031, 0.0217, -0.093];
            band('type') = 'hole';
            band('precision') = 200;
            
            n = FillingFraction(band);
            
            % Note the following:    
            % 1) It is known that the old one forgets to divide by 8pi^3
            % but other than that it should correspond.
            % 2) Also it is known that the k00 factor is forgotten 
            % in the calculation of kf, but set to 0 here.
            old = 0.8591 / (8 * pi^3);
            obj.verifyLessThan(abs(old - n), old / 100);
            
            
            % To make sure the old mistake is not re-introduced
            band('kcoeff') = [0.1, -0.02, 0.031, 0.0217, -0.093];
            n2 = FillingFraction(band);
            obj.verifyGreaterThan(abs(old - n2), old);
            obj.verifyLessThan(abs(0.0162 - n2), 0.001);
        end %testMemoryTetragonal
        
    end %methods
end
