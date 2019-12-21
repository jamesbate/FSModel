function filepath = IOPathSettings(settings, handles)
% Make the paths where the state has to be saved in the data folder.
%
% Responsibility: Low level path manipulation

% ends in a char, no \
direc = GetFolderLocation(settings, handles);
filepath = sprintf('%s\\programSettings.txt', direc);
end %IOPathOrbits
