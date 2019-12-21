function OrbitalDistributionLauncher(handles, settings)
% Create a plot where the frequency is shown as it changes along the
% magnetic field direction.
%
% Responsibility: Separate physics from IO and Settings

bands = ExtractParameters(settings);
[freqfig, coverfig] = MultiOrbitalDistribution(bands);
[freqloc, coverloc] = IOPathDistribution(settings, handles);

figure(freqfig);
SaveFigure(freqloc);

figure(coverfig);
SaveFigure(coverloc);
end %OrbitalDistributionLauncher
