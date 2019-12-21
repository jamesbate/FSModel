function SwitchSymmetry(handles, settings, symmetry)
% Update tight binding modes, available bands, symm properties
% Forward to SwitchBand to make sure the GUI state remains valid.

% Task 1: symm itself
kmodes = GetKModes(symmetry);
SetKModes(handles, kmodes);
settings.set('Symmetry', symmetry);

% Task 2: bands
bands = GetBands(settings, symmetry);
[~, bandID] = CurrentState(settings);
MakeAndSetBandMenu(handles.BandMenu, bands, bandID);

% Task 3: symm properties
GetAndSetSymmetryProperties(handles, settings, symmetry);

% Task 4: init band
SwitchBand(handles, settings, bandID);
end %SymmetrySwitch


function SetKModes(handles, kmodes)
% Set the textboxes of the coefficients to express what 
% symmetry type is entered into which box.

if length(kmodes) > 10
    error('There are only 10 places on the GUI, this symmetry has %d', ...
          length(args));
end

for ind = 1:length(kmodes)
   key = sprintf('TB%02d', ind);
   obj = handles.(key);
   obj.String = kmodes(ind);
end %for

for ind = length(kmodes) + 1:10
   key = sprintf('TB%02d', ind);
   obj = handles.(key);
   obj.String = '';
end %for
end %SetKModes


function MakeAndSetBandMenu(menu, bands, bandID)
% Overwrite the GUI options and select this one.

menu.String = bands;
if ~ismember(bandID, bands)
    fprintf('> BandID %s does not exist, default to "Select Band"\n', ...
            bandID);
    bandID = 'Select Band';
end

index = find(strcmp(bands, bandID), 1);
menu.Value = index;
end %SetBandMenu


function GetAndSetSymmetryProperties(handles, settings, symmetry)
% Initiate the lattice and magnetic field parameters.

props = {'B', 'BAzumithal', 'BPolar', 'Lattice1', 'Lattice2', ...
         'Lattice3', 'AtomsPerCell', 'Precision'};
edits = {'BEdit', 'BAzumithalEdit', 'BPolarEdit', 'Lattice1Edit', ...
         'Lattice2Edit', 'Lattice3Edit', 'AtomsPerCellEdit', 'PrecisionEdit'};
defaults = {'10', '0', '0', '3', '3', '5', '1', '150'};
     
if strcmp(symmetry, 'Choose Symmetry Group')
    for ind = 1:length(props)
        handles.(props{ind}).String = '';
        handles.(edits{ind}).String = '';
        set(handles.(edits{ind}), 'enable', 'off');
    end
else
    for ind = 1:length(props)
        set(handles.(edits{ind}), 'enable', 'on');
        key = MakeSettingsKey(props{ind}, symmetry);
        value = settings.get(key, defaults{ind});
        handles.(props{ind}).String = value;
        handles.(edits{ind}).String = value;
    end
end
end %GetAndSetSymmetryProperties
