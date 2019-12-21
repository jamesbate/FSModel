classdef OutputExtremalOrbit < handle
% Encapsulate the results of MultiExtremalOrbits.
%
% Properties:
%   <None>
% Methods:
%   Update(centres, freqs, times, bandid)
%   GetResult()
    
properties (Access = private)
    astext;
    result;
    lastID;
end %properties
    
methods 
    function obj = OutputExtremalOrbit(astext)
        % Initiate the object data structures.
        % You have to choose astext on initiation and cannot return.
        obj.astext = astext;
        if astext
            obj.result = sprintf('%s\n%s%s\n\n', ...
                                 'Extremal orbits:', ...
                                 '<distance to origin | freq in T ',...
                                 '| period in ps>');
        else
            obj.result = {};
        end 
    end %OutputExtremalOrbit
    
    function Update(obj, dists, freqs, dfreqs, times, bandid)
        % Add these extremal orbits to the result
        %
        % Centres : array of double
        %       <kz>*c of this orbit. Gives the user an idea of where it
        %       is on the Fermi surface when there are many orbits.
        % Freqs : array of double
        %       Corresponding dHvA/SdH frequencies.
        % dfreqs : array of double
        %       Correspondong array of uncertainties in frequency.
        % Times : array of double
        %       Corresponding traversal time of these extremal orbits.
        % bandid : int
        %       Useful if you want to know which extremes match and 
        %       which band it was that this data came from,
        %       every update can have its own 'batch id'
        %
        
        if obj.astext
            if isempty(obj.lastID) || ~strcmp(obj.lastID, bandid)
                obj.lastID = bandid;
                obj.result = sprintf('\n%sBand %s:\n', obj.result, bandid);
            end
            for ind = 1:length(freqs)
                obj.result = sprintf('%s> %7.4e | %7.2f +- %.1e | %7.3f\n', ...
                                 obj.result, dists(ind), freqs(ind), ...
                                 dfreqs(ind), times(ind) * 1e12);
            end %for
        else
            obj.result{end + 1} = {bandid, dists, freqs, times};
        end
    end %Update
    
    
    function r = GetResult(obj)
        % Obtain the result, textual or numerical.
        r = obj.result;
    end %GetResult
end %methods
end %OutputExtremalOrbit
