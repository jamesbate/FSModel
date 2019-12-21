function [symm, bandID] = CurrentState(settings)
% Get the current symmetry and band from settings.
% Please always ask this information here and not directly through settings

% Symmetry has to exist after the start up of the program or something 
% is off and an error is caused here.
symm = settings.get('Symmetry');

% Band however may not exist yet for this particular setting
key = MakeSettingsKey('BandID', symm);
bandID = settings.get(key, 'Select Band');
if isnan(str2double(bandID))
   settings.set(key, 'Select Band');
   bandID = 'Select Band';
end
end %CurrentState
