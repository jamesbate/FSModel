function SwitchBand(handles, settings, bandID)
% Read in the band properties from settings.
% Uses symmetry from settings.


[symmetry, ~] = CurrentState(settings);
% Recursion to create a new band
if strcmp(bandID, 'New Band')
    bandID = MakeNewBand(handles);
    if strcmp(bandID, 'New Band') 
        error('Recursion bug while creating new band.');
    end
    SwitchBand(handles, settings, bandID);
    return
end
    
% Notice that empty kmodes here does NOT mean there are no
% symmetry modes for this symmetry, it only means none are looked up 
% for a numerical value and that all edit boxes will be greyed out.
kmodes = GetKModesSpecial(symmetry, bandID);
GetAndSetBandCoeff(handles, settings, symmetry, bandID, kmodes);
GetAndSetBandProps(handles, settings, symmetry, bandID);
settings.set(MakeSettingsKey('BandID', symmetry), bandID);
SetGUIBand(handles, bandID);
end %BandCoefficientsSwitch


function kmodes = GetKModesSpecial(symmetry, bandID)
% Derive the kmodes from function signature
% Adds band specificity - error on New Band (should not enter here)
% and empty for Select Band

if strcmp(bandID, 'Select Band')
    kmodes = [];
elseif strcmp(bandID, 'New Band')
    error('New Band should not propagate here.');
else
    kmodes = GetKModes(symmetry);
end
end %GetKModesSpecial 


function bandID = MakeNewBand(handles)
% Determine how many band IDs exist and make the next in line.
% Then set focus to it and return the ID

menu = handles.BandMenu;
options = menu.String;
last = str2double(options{end});
if isnan(last)
    options{end + 1} = '01';
else
    options{end + 1} = sprintf('%02d', last + 1);
end
menu.String = options;
guidata(menu, handles);
bandID = options{end};
menu.Value = length(options);
end %MakeNewBand


function GetAndSetBandCoeff(handles, settings, symmetry, bandID, kmodes)
% Get from settings, set into the GUI
%
% Note that this function is responsible for creating all the 
% settings for the coefficients.
% Note that 'Select Band' will not create any kmodes in settings because
% the list of '1st component' etc are not passed here but 
% an empty list is given
% Note that 'New Band' will not traverse this code and also has no
% settings made for it.
% This is important because the rest of the program will only stop
% its execution if settings do not exist, otherwise it may continue
% with whatever is in there.

if strcmp(bandID, 'New Band')
    error('New Band should not propagate here');
end

% The actual k modes default to value 0
% The enabling is mostly redundant, but if there was a switch
% from another symmetry with a different number of kmodes,
% it is necessary and in any case it is not time consuming. 
% It is here considered better to keep branching down.
for ind = 1:length(kmodes)
    key = MakeSettingsKey(kmodes{ind}, symmetry, bandID);
    value = settings.get(key, '0');
    obj1 = handles.(sprintf('Coeff%02d', ind));
    obj2 = handles.(sprintf('CoeffEdit%02d', ind));
    obj1.String = value;
    obj2.String = value;
    set(obj2, 'enable', 'on');
end

% The redundant modes have to be overridden to empty
% and prevent the user from entering anything into them.
for ind = length(kmodes) + 1:10
    obj1 = handles.(sprintf('Coeff%02d', ind));
    obj2 = handles.(sprintf('CoeffEdit%02d', ind));
    obj1.String = '';
    obj2.String = '';
    set(obj2, 'enable', 'off');
end
end %SetBandCoeff


function GetAndSetBandProps(handles, settings, symmetry, bandID)
% Read in scattering time etc.
% This function is sensitive to being out of sync with the API
% if new band properties are added. Make sure to read in all of them.
%
% Note that these will be skipped for 'Select Band'
% but should not be made for 'New Band' as that option recurses before this

props = {'KxOffset', 'KyOffset', 'KzOffset', 'EffMass', 'Tau'};
edits = {'KxOffsetEdit', 'KyOffsetEdit', 'KzOffsetEdit', 'EffMassEdit', ...
         'TauEdit'};
defaults = {'0', '0', '0', '1', '100'};

if strcmp(bandID, 'Select Band')
    for ind = 1:length(props)
        handles.(props{ind}).String = '';
        handles.(edits{ind}).String = '';
        set(handles.(edits{ind}), 'enable', 'off');
    end
    
elseif strcmp(bandID, 'New Band')
    error('New Band should not propagate here.');
    
else
    for ind = 1:length(props)
        key = MakeSettingsKey(props{ind}, symmetry, bandID);
        set(handles.(edits{ind}), 'enable', 'on');
        value = settings.get(key, defaults{ind});
        handles.(props{ind}).String = value;
        handles.(edits{ind}).String = value;
    end
end
end %GetAndSetBandProps


function SetGUIBand(handles, bandID)
% Generally does nothing
% But if you call SwitchBand programmatically instead of through the GUI
% for example when deleting a band, the GUI has to be explicitly set
% to what you are switchin to.

options = handles.BandMenu.String;
position = find(strcmp(options, bandID), 1);
handles.BandMenu.Value = position;

end

