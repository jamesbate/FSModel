function p = SettingsPath(name, check)
% Make a settingspath given the name.
% name : string
% check (optional, true) : bool  <make file if it does not exist>
%
% Name cannot contain spaces, extensions, / or \ 
% Also has to be a valid filename alongside the above requirements.

if ismember(' ', name)
    error('Setting:Reserved', ...
          'Settingsname contains a forbidden space (to be safe).');
elseif ismember('.', name)
    error('Setting:Reserved', ...
          'Settignsname contains a forbidden dot (no extensions!).');
elseif ismember('/', name) || ismember('\', name)
    error('Setting:Reserved', ...
          'Settignsname contains a forbidden / or \\ (no movement).');
elseif isempty(name)
    error('Setting:Reserved', 'Settingsname cannot be empty');
end

[thisDir, ~, ~] = fileparts(mfilename('fullpath'));
p = strcat(thisDir, '\', name, '.txt');

if nargin > 1 && check
    if ~exist(p, 'file')
        fclose(fopen(p, 'w'));
    end
end
end %SettingsPath
