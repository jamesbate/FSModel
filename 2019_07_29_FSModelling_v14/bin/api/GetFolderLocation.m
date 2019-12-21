function datapath = GetFolderLocation(settings, handles)
% Obtain the current folder. 
% Handles is used to update the GUI only
% It is made a requirement to make sure there is sync, but it does not
% normally do anything.
% The directory ends in a character, NOT a \

direc = settings.get('FolderName', 'default');
handles.FolderNameValue.String = direc;

% Move 1 directory up to reach the main folder of FSModelling.
% The last \ separates the filename from the directory
% The one-to-last is where the parent directory name ends.
[here, ~, ~] = fileparts(mfilename('fullpath'));
indices = strfind(here, '\');
main = here(1:indices(end - 1));

% Move to the data directory
datapath = strcat(main, 'data\', direc);

% Make sure the path exists.
% If this throws, then it stops any writing, but it does not 
% prevent the user from changing it to something valid, so let it happen.
if ~exist(datapath, 'dir')
    mkdir(datapath);
end
end
