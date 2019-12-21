function location = IOPathLSurface(settings, handles)
% Make the path where the figure has to be saved.
% Responsibility: Low level path manipulation

% ends in a char, no \
direc = GetFolderLocation(settings, handles);
name = 'LSurfacePlot';
location = sprintf('%s\\%s.fig', direc, name);
end %IOPathFermiSurfaceVelocity
