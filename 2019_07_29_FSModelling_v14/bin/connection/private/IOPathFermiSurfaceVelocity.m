function location = IOPathFermiSurfaceVelocity(settings, handles, addVelocity)
% Make the path where the figure has to be saved.
% Responsibility: Low level path manipulation

% ends in a char, no \
direc = GetFolderLocation(settings, handles);
if addVelocity
    name = 'FermiVelocityPlot';
else
    name = 'FermiSurfacePlot';
end

location = sprintf('%s\\%s.fig', direc, name);
end %IOPathFermiSurfaceVelocity
