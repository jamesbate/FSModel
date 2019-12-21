function SetFolderLocation(settings, direc)
% Initiate a new data directory. Existing or new.

if isempty(direc)
    direc = 'default';
end
settings.set('FolderName', direc);
GetFolderLocation(settings);
end %SetFolderLocation
