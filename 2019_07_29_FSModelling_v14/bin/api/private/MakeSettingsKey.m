function fullkey = MakeSettingsKey(key, symm, band)
% Make the complete key you can forward to settings.
% band (optional) : only provide if this is a band specific prop.
% symm (optional) : only provide if this is a symm OR band specific prop.
% key : always provide
%
% This simply defines the format for the key, to make sure a minimal 
% number of spelling mistakes are made and that if something is off
% there is a place where it can be tracked.
%
% Get symm/band through CurrentState!

if nargin == 3
    fullkey = sprintf('%s Band %s: %s', symm, band, key);
elseif nargin == 2
    fullkey = sprintf('%s: %s', symm, key);
else
    fullkey = key;
end %MakeSettingskey