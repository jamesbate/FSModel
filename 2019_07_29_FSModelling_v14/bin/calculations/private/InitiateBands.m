function input = InitiateBands(input)
% Turn a single band into a cell of bands, a cell of bands as it is
% an empty input to an error 
%
% Responsibility: Low level code to merge input formats
%
% Turns 'kcoeff' properties into a cell array if it isnt already.

if isempty(input)
    error('No bands given.');
elseif ~iscell(input)
    input = cell(bands);
end

for ind = 1:length(input)
    band = input{ind};
    if ~isa(band, 'containers.Map')
        error('Input #%d is not a containers.Map', ind);
    end 
    
    if ~iscell(band('kcoeff'))
        band('kcoeff') = num2cell(band('kcoeff'));
        input{ind} = band;
    end
end %for
end %MakeCellOfBands
