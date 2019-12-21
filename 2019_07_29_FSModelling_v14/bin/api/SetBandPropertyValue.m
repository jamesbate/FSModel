function SetBandPropertyValue(hObject, handles, id)
% Id is a string, e.g. 'tau'
% Overwrites a property just entered in the API
% Combats code duplication by combining multiple fields
% 
% Takes care of 'EffMass', 'KxOffset', KyOffset'
% The GUI objects showing the settings value have this name
% The settings have this id as well (with symmetry & band ID added)

% Have to make this strict
% Otherwise random settings are being created and more nonsense,
% it can get out of control
options = {'EffMass', 'KxOffset', 'KyOffset', 'KzOffset', 'Tau'};
if ~ismember(options, id)
    error('Unknown id %s', id);
end

try
    value = str2double(get(hObject, 'String'));
catch
    return;
end %try
if isnan(value)
    return;
end

settings = handles.settings;
[symm, bandID] = CurrentState(settings);
key = MakeSettingsKey(id, symm, bandID);
obj = handles.(id);
settings.set(key, value);
obj.String = settings.get(key);
end %SetBandPropertyValue