function options = GetBands(settings, symmetry)
% Read from the settings which band options are available.
% 'Select Band' is always available.
% 'New Band' is avaialble unless symmetry is 'Choose Symmetry Group'
% The rest is made available consecutively from 01 based 
% on the availability of settings.
%
% options is a cell array of options
% You can directly set this to a menu handle following
% <Menu>.String = options;

options = repmat('', 1, 0);
options{1} = 'Select Band';
if strcmp(symmetry, 'Choose Symmetry Group')
    return
end

options{2} = 'New Band';

index = 0;
while true
    index = index + 1;
    bandID = sprintf('%02d', index);
    key = MakeSettingsKey('EffMass', symmetry, bandID);
    try
        settings.get(key);
    catch
        break;
    end %try
    options{index + 2} = bandID;
end % while
end %GetBand