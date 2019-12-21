function OrbitPlotLauncher(handles, settings)
% Extract the bands
% Calculate their extremal orbits
% Plot the extremal orbits on top of a Fermi surface
% Show and save the orbit areas and frequencies.
%
% Responsibility: Separate physics from IO and Settings

bands = ExtractParameters(settings);

string = MultiExtremalOrbit(bands, true);
hold on;
MultiFermiSurfacePlot(bands, 0);
view([-1,-1,1]);

[figloc, txtloc] = IOPathOrbits(settings, handles);
SaveFigure(figloc);
SaveMessage(txtloc, string);
end %OrbitPlotLauncher




