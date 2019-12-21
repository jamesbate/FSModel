function SetCoefficientValue(hObject, handles, id)
% Overwrite the value of 1 kmode. 
% id is the textbox number where this is called from.
% i.e. which k mode has to be changed.
%
% hObject : editbox [one of the kmodes]
% handles : the state of the program
% id : int between 1 and 10
%
% This is really focused on code duplication reduction / DRY

if id > 10 || id < 1
    error('Illegal id.');
end

value = str2double(get(hObject, 'String'));
if isnan(value)
    objname = sprintf('TB%02d', id);
    name = handles.(objname).String;
    display(name);
    msgbox(sprintf('The value of Coeff%02d (%s) is invalid.', id, name));
    return
end

settings = handles.settings;
[symm, bandID] = CurrentState(settings);
kmodes = GetKModes(symm);

if length(kmodes) < id
    msgbox('There are only %d k modes, cannot set number %d', ...
           length(kmodes), id)
   return
end

key = MakeSettingsKey(kmodes{id}, symm, bandID);
cname = sprintf('Coeff%02d', id);
obj = handles.(cname);
settings.set(key, value);
obj.String = settings.get(key);
end %SetCoefficientValue
