function RemoveBand(handles, settings)
% Remove all settings referencing the current band.
% Then remove it from the GUI and move to 'Select Band'
% Does nothing if currently on 'Select Band' or 'New Band'

[symm, band] = CurrentState(settings);

if strcmp(band, 'Select Band')
    return;
elseif strcmp(band, 'New Band')
    return;
end

masterkey = MakeSettingsKey('', symm, band);
RemoveAllSubkeys(settings, masterkey);
DecreaseBandIDs(settings, symm, str2double(band) + 1);

options = GetBands(settings, symm);
handles.BandMenu.String = options;
guidata(handles.BandMenu);
SwitchBand(handles, settings, 'Select Band');

end %RemoveBand


function RemoveAllSubkeys(settings, masterkey)
% Delete all keys in settings which contain the masterkey.

allkeys = settings.getKeys();
len = length(allkeys);
ind = 1;

while ind <= len
    if isempty(strfind(allkeys{ind}, masterkey))
        ind = ind + 1;
    else 
        settings.remove(allkeys{ind});
        allkeys = settings.getKeys();
        len = length(allkeys);
    end
end %while
end %RemoveAllSubkeys


function DecreaseBandIDs(settings, symmetry, bandNum)
% Example: startID 4 means 4, 5, 6, 7 go to 3, 4, 5, 6
% and the maximum 7 is determined by the existance of any key in the band.

% The loop is capped for safety against infinite recursion if a bug 
% occurs and the count does not return 0 properly.
% This is a very conservative line, but that 0 depends on the proper 
% workings of settings and functions outside of the control of this func.
for ind = 1:100
    bandID = sprintf('%02d', bandNum);
    newID = sprintf('%02d', bandNum - 1);
    masterkey = MakeSettingsKey('', symmetry, bandID);
    newkey = MakeSettingsKey('', symmetry, newID);
    
    count = RenameAllSubkeys(settings, masterkey, newkey);
    if count == 0
        break;
    end
    bandNum = bandNum + 1;
end %for
end %DecreaseBandIDs


function amount = RenameAllSubkeys(settings, masterkey, renamed)
% Rename settings such that masterkey => renamed as subpart of settings.
% Does not care about overwriting any existing keys containing renamed.
% Returns the number of renamed settings.

amount = 0;
allkeys = settings.getKeys();

for ind = 1:length(allkeys)
    oldkey = allkeys{ind};
    if ~isempty(strfind(allkeys{ind}, masterkey))
        newkey = strrep(oldkey, masterkey, renamed);
        value = settings.get(oldkey);
        settings.set(newkey, value);
        settings.remove(oldkey);
        amount = amount + 1;
    end
end %for
end %RenameAllSubkeys

