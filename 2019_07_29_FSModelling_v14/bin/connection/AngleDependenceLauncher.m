function AngleDependenceLauncher(handles, settings)
% Make a plot of (angle, frequency) at the current bPsi direction.
% Save the result in a figure and .orbit.mat file complementing FSPlotter
% Makes a prompt to set the theta values.
%
% Responsibility: Separate physics from GUI, IO and Settings
%
% This launcher does quite a few things with IO.

bands = ExtractParameters(settings);
[figpath, datapath] = IOPathAngleDependence(settings, handles);
theta = AskThetaValues(settings);
if isequal(theta, -1)
    return;
end
theta = theta .* pi/180;
output = MultiAngularFrequency(bands, theta);
output.Save(datapath);
SaveFigure(figpath);
settingspath = IOPathSettings(settings, handles);
copyfile(settings.filepath, settingspath);
end %AngleDependenceLauncher
