classdef ComputationalGeometry < handle
% Takes a geometry and allows you to do various quite non-trivial
% computations over them. Please refrain from using .geometry.SetDirection
% or you'll screw over the memory this has obtained.
  

properties (SetAccess = private)
    geometry;
end

properties (Access = private)
    nodesA = -1;
    nodesB = -1;
    sections = -1;
end %properties

methods
    % Added functionality
    % It is all about going from the geometry to having a way 
    % to cover all the orbits exactly once, robustly, even if there
    % are many nodes and discontinuities.
    function obj = ComputationalGeometry(geometry)
        obj.geometry = geometry;
        obj.SetDirection(geometry.Upolar, geometry.Uazumithal);
    end %Constructor
    
    function [aa, bb] = Nodes(obj)
        % Get the area=0 points on the surface given the direction.
        % Compute them if they are not readily memorized.
        %
        % Note that this is necessary information for basically everything
        % else in ComputationalGeometry, but if it is needed and you did 
        % not call this in advance or changed direction in the meantime,
        % the other methods will be graceful and call this for you.
        if obj.nodesA == -1
            [obj.nodesA, obj.nodesB] = CoverageNodes(obj.geometry);
        end
        aa = obj.nodesA;
        bb = obj.nodesB;
    end %Nodes

    function [t, path] = Topology(obj, a, b)
        % Obtain the topology classification of the orbit starting here.
        %
        % Topology means one of 3 things:
        %   - the nodes enclosed by the orbit
        %   - -1 if the (a,b) space orbit is not closed (wraps figure)
        %   - empty if the path did not complete
        obj.Nodes();
        [t, path] = CoverageTopology(obj.geometry, a, b, ...
                                     obj.nodesA, obj.nodesB);
    end
        
    function sections = WalkAway(obj, nodeID, angle)
        % Given a node, walk away till the point where wrapping orbits
        % are encountered. The walk is divided into sections where the
        % topology of the orbits is different, with minimal space in
        % between to dodge discontinuities.
        %
        % sections is a cell array of structs with 
        %   .alpha
        %   .beta
        %       2-vectors for start and end position
        %   .topology
        %       the enclosed nodes.
        %       Note that small sections in between regions
        %       have topology empty and are also included.
        %
        % Note that sections{1}.alpha is the node, 
        % Note that sections{end}.beta is the start of wrapping orbits.
        % Note that this has NO memory, so you pay for each call.

        obj.Nodes;
        a = obj.nodesA(nodeID);
        b = obj.nodesB(nodeID);
        sections = CoverageEscapeAllCycles(obj.geometry, obj.nodesA, ...
                                           obj.nodesB, a, b, angle);
    end %WalkAway
    
    function sections = Sections(obj)
        % Using all the nodes and their walk aways, create a path
        % that traverses all the topologically distinct areas. 
        % This will return a path and not points such that you can 
        % discretise them however you like.
        %
        % See '.WalkAway' for a description of sections.
        % Note that this HAS memory, so unless you change angles
        % you pay only for the first call and subsequent are free.
        
        if isnumeric(obj.sections)
            obj.Nodes();
            
            
            if isempty(obj.nodesA)
                obj.sections = CoverageTrivialSections();
            else
                obj.sections = CoverageSections(obj.geometry, obj.nodesA, obj.nodesB);
                %obj.sections = CoverageAllSections(obj.geometry, obj.nodesA, obj.nodesB);
            end
        end
        sections = obj.sections;
    end %Sections 
    
    function [aa, bb] = Cover(obj, amount, nans)
       % Make a set of points which combined cover the entire object 
       % if you follow their orbits.
       %
       % There will be *roughly* amount orbits, they will be 
       % equidistantly spaced in geometry.CalcDistant, there may be 
       % some *more* orbits when you have duplicate orbits at a single
       % distance or if you have very small limit cycles
       %
       % Calls obj.Sections so if you have not computed that yet, you will 
       % pay to generate this the first time, but afterwards there is 
       % memory and it will be quick.
       %
       % If nans is set, put a NaN in both aa,bb between sections such 
       % that you can separate clearly between them without having to
       % bother to linearize everything yourself. Defaulted to true.
       
       if nargin < 3
           nans = true;
       end
       
       obj.Sections();
       [aa, bb] = CoverageDistributePoints(obj.geometry, obj.sections, amount, nans);        
    end
    
    
    function results = ExtremalAreas(obj)
        % Compute the extremal areas and where they are.
        % 
        % results : cell array of struct
        % struct with:
        %   .a
        %   .b        a point on the orbit
        %   .area     the area enclosed
        %   .darea    the uncertainty on the extremum
        %   .plane    the distance of this orbit along the direction
        %   .isMini   boolean
        obj.Sections();
        results = ExtremizeAreas(obj.geometry, obj.sections); 
    end
    
    function ShowCover(obj, amount, abspace)
        % Call .Cover() and plot those orbits on top of a view of the
        % geometry in a *NEW* figure. abspace is optional and default false
        [aa, bb] = obj.Cover(amount);
        
        figure;
        if nargin > 2 && abspace
            CoveragePlotOrbitsAB(obj.geometry, aa, bb);
        else
            PlotGeometry(obj.geometry, 'black');
            CoveragePlotOrbits(obj.geometry, aa, bb);
        end
    end
end%methods

methods
    % Forwarding to Geometry
    % Note that precision is not given, this may be extended in the future
    % but for me it is weird to have it and allow it to change.
    % Note that SetDirection has added implications
    
    function area = CalcArea(obj, a, b)
        % Calculate the area of the orbit going through (a,b)
        area = obj.geometry.CalcArea(a, b);
    end
    
    function path = CalcPath(obj, a, b, abspace)
        % Calculate the path of the orbit going through (a,b).
        % abspace is optional.
        %
        % if abspace is set, path is like (1000,2) in (a,b)
        % if abspace is unset / left out, path is like (1000,3) in (x,y,z)
        if nargin < 4
            abspace = false;
        end
        path = obj.geometry.CalcPath(a, b, abspace);
    end
    
    function d = CalcDistance(obj, a, b)
        % Calculate the distance along the geometry direction to the origin
        % Suitable also for arrays of a,b
        d = obj.geometry.CalcDistance(a, b);
    end
    
    function [X, Y, Z] = Points(obj, a, b)
        % Convert these point(s) from (a,b) to (x,y,z) space.
        [X, Y, Z] = obj.geometry.Points(a, b);
    end
    
    function [a,b] = FindPlane(obj, plane, a, b)
        [a,b] = obj.geometry.FindPlane(plane, a,b);
    end
    
    function SetDirection(obj, polar, azu)
        % Overwrite the angle to a new direction.
        %
        % Please REFRAIN from using .SetDirection on any remaining 
        % copies of geometry you own. If you do, by reference the copy 
        % this holds will be changed as well and it will screw any memory 
        % this has until you call SetDirection from here. 
        % There is no simple deepcopy in matlab sadly.
        
        if obj.geometry.Upolar==polar && obj.geometry.Uazumithal==azu
            return;
        end
        
        obj.nodesA = -1;
        obj.nodesB = -1;
        obj.sections = -1;
        obj.geometry.SetDirection(polar, azu);
    end %SetDirection
    
    
    function r = Ux(obj)
        r = obj.geometry.Ux;
    end
    
    function r = Uy(obj)
        r = obj.geometry.Uy;
    end
    
    function r = Uz(obj)
        r = obj.geometry.Uz;
    end
    
    function r = Uazumithal(obj)
        r = obj.geometry.Uazumithal;
    end
    
    function r = Upolar(obj)
        r = obj.geometry.Upolar;
    end
    
end %methods
end %ComputationalGeometry
