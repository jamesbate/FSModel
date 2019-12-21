classdef Geometry < handle

    properties
        maxPathLength = 30000;
    end
    
    properties (SetAccess = private)
        Ux = 0;
        Uy = 0;
        Uz = 1;
        precision;
        Upolar = 0;
        Uazumithal = 0;
    end %properties
    
    properties (Access = private)
        dA;
        dB;
        fSurface;
        args;
    end %properties
    
    methods  
        function obj = Geometry(fSurface, precision, varargin)
           % Construct a fermi surface to analyse.
           %
           % fSurface is f : [R, R] => [R, R, R]
           % a 2-dimensional parametrization of a 3-dimensional surface.
           % precision : int
           %    Recommended ~150, stepsizes along orbits are ~pi/precision.
           %
           % The real requirement for fSurface is that the first argument
           % runs through the object [0, 2*pi], whereas the second argument
           % is more strict and requires [x,y,z] periodicity over [0,
           % 2*pi]. Volumes for example are made by stepping through the
           % first argument and using [0, 2*pi] curves over the second.
           % This allows both closed shapes (sphere) and open (cilinder).
           % NOT ok: f(phi, theta), volumes fail due to crossing lines
           %     OK: f(theta, phi), parallel circles.
           % You could do a sphere also through z=(theta-pi)/2pi * radius
           % and let x = sqrt(radius-z^2) cos(phi) and y similar. No
           % problem, seen as second argument slices you need enclosing
           % non-crossing closed curves that is the only limitation. Though
           % some parametrizations are more homogeneous than others which
           % helps convergence, but that is another matter.
           obj.fSurface = fSurface;
           obj.SetPrecision(precision);
           obj.args = varargin;
        end %Constructor
        
        function [x, y, z] = Points(obj, a, b)
            % Get one or more points from the surface.
            [x, y, z] = obj.fSurface(a, b);
        end
        
        function [a, b] = FindPlane(obj, distance, aa0, bb0)
            % Find a point (a,b) on the plane given by distance.
            %
            % Precision of these points is <1e-8 in both 
            % parameters, independent of obj.precision and really ~2e-9.
            % 
            % aa0 and bb0 are optional, if given then start here with the
            % search. If not given then a bunch of starting points is tried
            % until one hits the mark. You can give multiple points, 
            % in which case this iterates till a success is found.
            % If nothing yields, then raise.
            
            adummy = [0.65, pi+0.65, pi+0.65, 0.65, ...
                   0.65+pi/2, 0.65-pi/2, 0.65+pi/2, 0.65-pi/2];
            bdummy = [0.47, pi+0.47, 0.47, pi+0.47, ...
                      0.47+pi/2, 0.47-pi/2, 0.47-pi/2, 0.47+pi/2];
            dRef = max(abs(obj.CalcDistance(adummy,bdummy)));
            if nargin < 3
                aa0 = adummy;
                bb0 = bdummy;
            end
                   
            acc = 1e8;            
    
            % Let this be clear: NewtonRaphson is most of the time the
            % best. Except near significantly corrugated points where the
            % derivative exceeds 1. Then Newton diverges and walking is
            % just a robust point to fall back on. Newton is 3-7 times
            % faster depending on all sorts of factors, but enough that it
            % is worth it to try Newton first, even if it fails 5% of the
            % time or something like that.
            %
            % Also note that this exception path is taken in the test suite.
            for ind = 1:length(aa0)
                a0 = aa0(ind);
                b0 = bb0(ind);
                try
                    pos = NewtonRaphson(@(xx)obj.CalcDistance(xx(1), xx(2)), ...
                                        distance, ...
                                        [a0, b0], ...
                                        1/acc/10, 1/acc, 0, 1000);            
                    a = pos(1);
                    b = pos(2);
                catch
                    [a, b] = WalkingDescend2(@(A, B) abs(obj.CalcDistance(A, B) - distance), ...
                                             a0, b0, pi/10, pi/10, 1, acc, ...
                                             0, 2*pi, 0, 2*pi, true);
                end %try
                
                if abs(obj.CalcDistance(a, b) - distance) < 1e-5 * dRef
                    return;
                end
            end %for
            
            error('Could not find the plane %.3e.', distance);
        end %FindPlane
        
        function d = CalcDistance(obj, a, b)
            % Convert (a,b) to r=(x,y,z), then calculate dot(r, direction).
            [x, y, z] = obj.fSurface(a, b, obj.args{:});
            d = obj.Ux * x + obj.Uy * y + obj.Uz * z;
        end %CalcDistance
        
        function path = CalcPath(obj, a, b, space2)
            % Create the 3-space path(100+,3) starting at (a,b)
            % If space2 is set (optional, default false), get it in (a,b)
            % which means path(100+,2);
            fDist = @obj.CalcDistance;
            
            % Note: the orbit has to finish [true], this is then assumed.
            path = MarchingSquare(fDist, a, b, obj.dA, ...
                                  obj.dB, obj.maxPathLength, ...
                                  true, [2*pi, 2*pi]);
            if nargin > 3 && space2
                return;
            end
            [xx, yy, zz] = obj.fSurface(path(:, 1), path(:, 2), obj.args{:});
            path = [xx, yy, zz];            
        end %CalcPath
        
        function [area, error] = CalcArea(obj, a, b)
            % Calculate the area of the orbit enclosed starting at (a, b)
            % 
            % If 2 args out, half precision and repeat for an error
            % estimate that should be OVERestimating the actual
            % error made here. The convergence is quadratic, so the
            % expected error is 1/4 of the given one, though often it turns
            % out 1/3 is a better guess.
            %
            % If you are so unlucky, the error calculation will set the
            % error to -1 if it fails, but the main area has to be
            % succesful
            
            % Primary calculation
            try
                path = obj.CalcPath(a, b);
            catch exc
                % If you are at a 0-sized orbit, then return it 
                % half precision means larger stepsize means always 
                % also a 0-sized orbit.
                if strcmp(exc.identifier, 'Marching:Starting')
                    area = 0;
                    error = 0;
                    return;
                else
                    rethrow(exc);
                end                
            end %try
                
            area = EnclosedAreaImplementation(path(1:end-1,1), ...
                                              path(1:end-1,2), ...
                                              path(1:end-1,3));
                   
            % Set precision to half for the error.
            % This is ONLY done if the error is actually requested, don't
            % waste a significant amount of time if it is not needed.
            if nargout > 1
                memory = obj.precision;
                obj.SetPrecision(floor(obj.precision/2));
                try
                    path = obj.CalcPath(a, b);
                    rough = EnclosedAreaImplementation(path(1:end-1,1), ...
                                                       path(1:end-1,2), ...
                                                       path(1:end-1,3));
                    error = abs(area - rough);
                catch
                    error = 0;
                end
                obj.SetPrecision(memory);
            end
        end %CalcArea
              
        function [volume, error] = CalcVolume(obj, delta)
            % Get the volume enclosed. Delta is the fractional error.
            % There is no extra cost with returning error.
            %
            % !!! It is more precise to use Cover of ComputationalGeometry
            % and do an integration over those orbits.
            if nargin < 2
                delta = 0.001;
            end
            if nargout == 1
                volume = EnclosedVolume(obj.fSurface, delta);
            else
                [volume, error] = EnclosedVolume(obj.fSurface, delta);
            end
        end %CalcVolume
        
        function SetDirection(obj, polar, azumithal)
            % Set the direction which all areas have to be orthogonal to.
            % Both input arguments in radians.
            obj.Ux = cos(azumithal) * sin(polar);
            obj.Uy = sin(azumithal) * sin(polar);
            obj.Uz = cos(polar);
            obj.Upolar = polar;
            obj.Uazumithal = azumithal;
        end %SetFieldDirection
        
        function SetPrecision(obj, precision)
            % Overwrite the precision of tracing orbits. 
            % A good default is 100-200, discretisation is 2pi/precision so
            % linear execution time and quadratic area convergence in it.
            obj.precision = precision;
            obj.dA = 2*pi / precision;
            obj.dB = 2*pi / precision;
        end
        
        function Plot(obj, color)
            % Make a plot of this geometry on a *new* figure
            figure;
            PlotGeometry(obj, color);
        end
        
    end %methods
end %Geometry

