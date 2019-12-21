classdef OutputLikeFSPlotter < handle
% Keep track of bands as more and more angles are analysed 
% for extremal orbits to make an output file compatible with 
% FSPlotter, as a contract for any further GUIs who want to use such 
% results and like to model their input properly.
%
% properties: 
%   <None>
% methods:
%   Save(filepath)
%   Update(band, angles, freqs, curves)
%   

properties (Access = private)
    available;
    map;
    allBands = {};
end
   
methods 
   
    function obj = OutputLikeFSPlotter()
        % Initiate an output object with all the required keys.
        obj.available = OutputColumns();
        obj.map = containers.Map();
        for ind = 1:length(obj.available)
            obj.map(obj.available{ind}) = [];
        end
    end %OutputLikeFSPlotter
    
    function AddBand(obj, band)
        % Add a new band to the mix.
        % Has to have an ID that does not clash with any existing bands.
        
        for ind = 1:length(obj.allBands)
            if isequal(obj.allBands{ind}('id'), band('id'))
                error('Cannot have two bands with the same id.');
            end
        end %for
        obj.allBands{end+1} = band;
    end %AddBand
    
    function Update(obj, result)
        % Add this result to the end of output. No sorting or whatever.
        % 
        % result : struct
        %   .angle : double
        %       polar angles where this magnetic field is located
        %   .freq : double
        %       matching array of dHvA/SdH frequencies
        %   .curvature : double
        %       d^2S/dB//^2
        %       Curvature of the area when moving along the field.
        %   .id : string
        %       identifies this band.
        %       Because reproducibility is to be guaranteed, it is required
        %       that this id exists among the bands given to this object.
        %       Has to be convertable to a number, e.g. '01'.
        %   .effmass : double
        %       the electron mass IN SI UNITS, so kg.
        
        %First verify the ID exists
        found = false;
        for ind = 1:length(obj.allBands)
            if strcmp(obj.allBands{ind}('id'), result.id)
                found = true;
                break;
            end
        end %for
        if ~found
            error('Result has band ID %s, which is not recognized.', result.id);
        end

        % Set up a way to keep done in line without risk
        done = {};
        function Add(property, value)
            obj.map(property) = Concatenate(obj.map(property), value);
            done{end+1} = property;
        end
        
        % Then convert the contents to the new data structure.
        Add('bandnum', str2double(result.id));
        Add('angle', result.angle * 180/pi);
        Add('freq', result.freq);
        Add('curvature', result.curvature);
            
        % Normally the abs is not necessary here, but I prefer to have 
        % the character correct rather than relying on code that is far
        % away to work correctly now and forever.
        if strcmp(result.type, 'electron')        
            Add('m_b', abs(result.effmass) / m0);
        else
            Add('m_b', -abs(result.effmass) / m0);
        end
 
        % All remaining columns have to keep up in length
        % The filler is NaN for easy filtering by others.
        allkeys = keys(obj.map);
        for ind = 1:length(allkeys)
            key = allkeys{ind};
            if isempty(find(strcmp(done, key), 1))
                obj.map(key) = Concatenate({obj.map(key), NaN});
            end
        end %for
    end %UpdateOutput
    
    function Save(obj, filepath)
        % Save the output as it is with a file structure compatible 
        % with FSPlotter (which modifies actual Wien2K calculations).
        
        colnames = OutputColumns();
        rows = length(obj.map(colnames{1}));
        data = zeros(rows, length(colnames));
        for ind = 1:length(colnames)
            coldata = obj.map(colnames{ind});
            if length(coldata) ~= rows
                error('Column %s has length %d, others have %d', ...
                      colnames{ind}, length(coldata), rows);
            end
            data(:, ind) = coldata;
        end %for

        % These variable names are enforced by FSPlotter.
        % Bands is added and useful for reproduction from a low level.
        rplotdata = data;
        bands = obj.allBands;
        save(filepath, 'colnames', 'rplotdata', 'bands');
    end %Save
    
end %methods
    
end %OutputLikeFSPlotter