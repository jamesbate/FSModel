function SafelyReplaceSettings(settings, filepath)
% Delete the current file and put in the given filepath
% Do so such that the old settings are restored when the operation failed.

location = settings.filepath;
indices = strfind(location, '\');
direc = location(1:indices(end));
temp = strcat(direc, 'temporary_file.temp');

% Step 1: Move the current settingsfile to free that path.
try
    movefile(location, temp);
catch exc
    msgbox(['Cannot replace settings, the settingsfile cannot be moved.', ...
            exc.message]);
end %try


% Step 2: Move the new file in
if ~copyfile(filepath, location)
    % Step 3, recover if failed (e.g. the file is open)
    move(temp, location);
    msgbox('Could not copy the new settings file');

% Step 4, delete the old settings after the above is succesful.
else
    delete(temp)
    msgbox('Settings loaded succesfully.');
end

% Step 5, update
% Do so without re-opening, which would be something like this:
% newsettings = MySettings(settings.name);
% delete(settings);
% newsettings.write();
keys = settings.getKeys();
for ind = 1:length(keys)
    settings.remove(keys{ind});
end %for
settings.read();


end %SafelyReplaceSettings.
