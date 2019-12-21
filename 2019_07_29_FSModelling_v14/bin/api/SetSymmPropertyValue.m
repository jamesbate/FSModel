function SetSymmPropertyValue(hObject, handles, id)
% ID is a string
% Combines the lattice values and magnetic field
% id is 'Lattice1', 'Lattice2' or 'Lattice3'
% 

% Have to make this strict
% Otherwise random settings are being created and more nonsense,
% it can get out of control
options = {'B', 'Lattice1', 'Lattice2', 'Lattice3', 'BAzumithal', ...
           'BPolar', 'AtomsPerCell', 'Precision'};
if ~ismember(options, id)
    error('Unknown id %s', id);
end

try
    value = str2double(get(hObject, 'String'));
catch
    msgbox('The value of "%s" is invalid.', id);
    return
end %try

settings = handles.settings;
[symm, ~] = CurrentState(settings);
key = MakeSettingsKey(id, symm);
obj = handles.(id);
settings.set(key, value);
obj.String = settings.get(key);
end %SetSymmPropertyValue



