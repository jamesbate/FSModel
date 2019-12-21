function filepath = SelectSettingsSavePath()
% Get a .txt path that does not yet exist.
% Return 0 upon failure.

filepath = 0;
dirpath = uigetdir();

if isequal(dirpath, 0)
    return;
end
name = inputdlg({'Enter file name'}, 'Filename', [1 35], ...
                {'FSModelling_Settings.txt'});
if isempty(name)
    return;
end
name = name{1};
if isempty(name)
    return;
end
if length(name) < 4 || ~strcmp(name(end-3:end), '.txt')
    name = strcat(name, '.txt');
end

filepath = fullfile(dirpath, name);
if exist(filepath, 'file')
    msgbox('File already exists.');
    filepath = 0;
end
end %SelectSettingsSavePath
