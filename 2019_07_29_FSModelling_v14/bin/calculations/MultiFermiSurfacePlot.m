function MultiFermiSurfacePlot(bands, mode)
% Make a plot with each of these bands on it on the *current* figure.
%
% bands : cellarray of bands or a single band.
% band : containers.Map with all the relevant properties
% mode : int
%   0 => Fermi surface, coloured by character (electron/hole)
%   1 => Fermi velocity vector size
%   2 => Fermi velocity azumithal component
%   3 => Fermi velocity in plane radial component
%   4 => Fermi velocity z component
%
% This high level function's responsibility is to separate the problem
% into these parts:
%   - Fermi surfaces
%   - Brillouin zone corners
%   - General figure layout/properties
%   - Legend
%
% Responsibility: Combine multiple FermiSurfacePlot and one 
%   BrillouinZoneCornersPlot and manage figure properties.


bands = InitiateBands(bands);
set(gcf, 'units','normalized','outerposition',[0 0.05 0.95 0.95]);
for ind = 1:length(bands)
    band = bands{ind};
    FermiSurfacePlot(band, mode);
    hold on;
end %for

BrillouinZoneCornersPlot(bands{1});
FSFigureProperties();
if mode == 0
    AddLegend({'electron', 'hole'}, {'red', 'blue'});
end
end %MultiFermiSurfacePlot
