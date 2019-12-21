function symm = SymmetryInitiate(handles, settings)
% Long and desync sensitive list which loads everything on the GUI

CheckSymmetries(handles);
symm = GetSymmetry(handles, settings);
SetSymmetry(handles, symm);
SwitchSymmetry(handles, settings, symm);

end %SymmetrySelection_Init


function CheckSymmetries(handles)
% Make sure all the GUI symmetries have an implementation
% Except for the first option - Choose Symmetry Group is always there.

symmOptions = handles.SymmetryMenu.String;
for ind = 2:length(symmOptions)
   % Throws if it cannot be properly created.
   GetKFermiFunc(symmOptions{ind}); 
end %for
end %CheckSymmetries


function symm = GetSymmetry(handles, settings)
% Symmetry: settings => GUI & return
%
% This is an extra step introduced upon startup because this is the moment
% where the key has to be made rather than just used.


menu = handles.SymmetryMenu;
symmOptions = menu.String;

try
    [symm, ~] = CurrentState(settings);
catch
    fprintf('> Making the Symmetry setting, likely no settings memory.\n');
    symm = symmOptions{1};
    settings.set('Symmetry', symm);
end
end %GetSymmetry


function SetSymmetry(handles, symmetry)
menu = handles.SymmetryMenu;
symmOptions = menu.String;
id = find(strcmp(symmOptions, symmetry), 1); 
set(menu, 'Value', id);
end %InitSymmetry
