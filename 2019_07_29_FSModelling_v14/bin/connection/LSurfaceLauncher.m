function LSurfaceLauncher(handles, settings)
% Create a plot of the velocity space surface.
%
% Responsibility: Separate File IO from plotting.

bands = ExtractParameters(settings);
filename = IOPathLSurface(settings, handles);
MultiLSurfacePlot(bands);
SaveFigure(filename);
end %LSurfaceLauncher