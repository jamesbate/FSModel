function result = ExtractParameters(settings)
% Make an object which contains all the current symm/band properties
% Contains ALL bands for THIS symmetry in particular.
% This is the end of the API.
% This object contains all the information for the next steps.
%
% The returned object is a cell array of Bands
% Each Band contains all the information about that band,
% lattice parameters, magnetic field, corrugations, everything

symmetry = settings.get('Symmetry');
if strcmp(symmetry, 'Choose Symmetry Group')
    error('Cannot extract paramters for the base symmetry.');
end

bandIDs = ExtractBandIDs(settings, symmetry);

result = cell(1, length(bandIDs));
for ind = 1:length(result)
    result{ind} = ExtractOneBand(settings, symmetry, bandIDs{ind});
end %for
end %ExtractParameters


function bandIDs = ExtractBandIDs(settings, symmetry)

bandIDs = cell(0, 1);
index = 0;
while true
    index = index + 1;
    bandID = sprintf('%02d', index);
    key = MakeSettingsKey('EffMass', symmetry, bandID);
    
    try
        settings.get(key);
    catch
        break;
    end %try
    
    bandIDs{index} = bandID;
end %while

end %ExtractBandIDs


function map = ExtractOneBand(settings, symmetry, bandID)
% Create a map from property to value for this band.
% Reads all of them from settings 
% AND converts them to SI units.
% Meaning rad, kg, meter, etc.

map = containers.Map;

% Band settings
function value = getKeyB(key)
    fullKey = MakeSettingsKey(key, symmetry, bandID);
    value = settings.get(fullKey);
end

% Symmetry settings
function value = getKeyS(key)
    fullKey = MakeSettingsKey(key, symmetry);
    value = settings.get(fullKey);
end
        
% General ones first
map('symmetry') = symmetry;
map('id') = bandID;
kmodes = GetKModes(symmetry);
map('kmodes') = kmodes;
map('path') = GetFolderLocation(settings);


% Then symmetry
map('B') = str2double(getKeyS('B'));
map('BAzumithal') = str2double(getKeyS('BAzumithal')) * pi / 180;
map('BPolar') = str2double(getKeyS('BPolar')) * pi / 180;
map('atomspercell') = str2double(getKeyS('AtomsPerCell'));
map('precision') = str2double(getKeyS('Precision'));
map('a') = str2double(getKeyS('Lattice1')) * 1e-10;
map('b') = str2double(getKeyS('Lattice2')) * 1e-10;
map('c') = str2double(getKeyS('Lattice3')) * 1e-10;


% Finally band
kvals = zeros(length(kmodes), 1);
for ind = 1:length(kmodes)
    kvals(ind) = str2double(getKeyB(kmodes{ind}));
end %for
map('kcoeff') = kvals * 1e10;

map('tau') = str2double(getKeyB('Tau')) * 1e-12;
mass = str2double(getKeyB('EffMass')) * m0;
map('effmass') = abs(mass);
if mass < 0
    map('type') = 'hole';
else
    map('type') = 'electron';
end

points = GetBrillouinCorners(symmetry, map('a'), map('b'), map('c'));
xmax = max(abs(points(1, :)));
ymax = max(abs(points(2, :)));
zmax = max(abs(points(3, :)));
map('kxoff') = str2double(getKeyB('KxOffset')) * xmax;
map('kyoff') = str2double(getKeyB('KyOffset')) * ymax;
map('kzoff') = str2double(getKeyB('KzOffset')) * zmax;

end
