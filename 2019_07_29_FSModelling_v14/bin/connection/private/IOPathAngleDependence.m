function [figpath, datapath] = IOPathAngleDependence(settings, handles)
% Get a path for the figure and full program output
% Responsibility: Low level path manipulation.

% ends in a char, no \
direc = GetFolderLocation(settings, handles);
indices = strfind(direc, '\');
dirname = direc(indices(end) + 1:end);

name = sprintf('%sOutput', dirname);
figpath = sprintf('%s\\%s.fig', direc, name);
datapath = sprintf('%s\\%s.orbit.mat', direc, name);
end %IOPathAngleDependence
