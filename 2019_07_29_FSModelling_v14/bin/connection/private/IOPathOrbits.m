function [figloc, txtloc] = IOPathOrbits(settings, handles)
% Make the paths where the orbits figure & text has to be saved.
%
% Responsibility: Low level path manipulation

% ends in a char, no \
direc = GetFolderLocation(settings, handles);
txtloc = sprintf('%s\\ExtremalOrbits.txt', direc);
figloc = sprintf('%s\\ExtremalOrbits.fig', direc);
end %IOPathOrbits
