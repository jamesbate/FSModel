function FermiSurfaceLauncher(handles, settings, mode)
% Make a plot of the Fermi Surface and Brillouin zone edges.
% Either with flat colors, or with velocity component(s).
% Saves the figure to the output directory
%
% mode : int
%   0 => Fermi surface, coloured by character (electron/hole)
%   1 => Fermi velocity vector size
%   2 => Fermi velocity azumithal component
%   3 => Fermi velocity in plane radial component
%   4 => Fermi velocity z component
%
% Responsibility: Separate the functional physics from IO and Settings.

figure;
bands = ExtractParameters(settings);
filename = IOPathFermiSurfaceVelocity(settings, handles, mode);
MultiFermiSurfacePlot(bands, mode);
SaveFigure(filename);
end %FermiSurfaceLauncher
