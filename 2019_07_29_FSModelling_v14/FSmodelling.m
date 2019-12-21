% This is the main code file for FSmodelling
% Backwards compatible with MATLAB 2016a
% Author: Roemer Hinlopen
% 
% Changelog:
% June 2016   - Last reported edit
% 07 May 2019 - Start Roemer: start refactoring AMROSim2D
% 09 May 2019 - Finish Settings, set up a file structure, unittests
% 15 May 2019 - Fixed bugs in Tetragonal k00, FeSe k12 and nr. electrons.
%               Changed nr electrons and FS functionality to general symm.
% 21 May 2019 - Changed orbits algorithm, though still no kz optimization
% 23 May 2019 - Change settings to be buffer with constr/destr IO.
%               Start all over, new GUI, no AMRO just modelling
%               which requires multi-band pictures and this is not simple
% 24-25 May 2019 - Make ExtractProperties as barrier between GUI & physics
%               Make the code backwards compatible with MATLAB 2016a
% 31 May 2019 - Version 1.0 is ready. Not bug free, but it can do all the
%               required things (Fermi Surface, Fermi Velocity, Orbits,
%               Angle Dependence, Saving like FSPlotter)
% 06 June 2019 - Version 1.1 is here. Deadline driven.
%               It has settings reset options, orbits at high angles
%               are now possible, the code is halfway restructured,
%               the L surface plot is implemented primitively.
% 25 June 2019 - Version 1.2 is bringing a major change.
%               The backend is now generalized and no longer restricted
%               to cilinders. There are also various other changes in the
%               program, most of which you won't see but would definitely
%               notice when they are not there. Most importantly, the 
%               issues with extremize at large angles have been pushed back
%               to >85 degrees when really everything is chaos and badness.
% 04 July 2019 - Version 1.3 improves further on the new representation,
%               using it to generate all the orbits exactly once 
%               such that resistivity (and any physical property just 
%               requiring the velocity/k-position evolution over time)
%               can be calculated. A lot of bugfixing and stabalizing has
%               also been done.
% 29 July 2019 - Version 1.4 improves the topology initial path such that
%               really any topology is properly covered and a torus not
%               with a bandaid. Also adds to the functionality as now 
%               the order of the parameters is irrelevant.
%               It fixes an issue where random non-extremal
%               orbits were occasionally picked up as extremal due to 
%               a numerical stability issue.
%
%
% Please inform Roemer Hinlopen of any bugs you may find
% r.hinlopen@student.ru.nl 
% Or if I am still around, talk to me.
% Or if you are reading this well past when I leave the RU,
% google me ;)
%
%
% Never move any of the GUI callback functions outside this main file.
% All direct callback should stay here.
%
% Each of the event functions has these arguments:
%   hObject : Object
%       the gui as a whole or the menu or the text class instance
%   eventdata : ActionData or empty
%       Ignore it, never used. 
%       Basically contains information on what trigger caused the call.
%   handles : struct
%       Really just a dictionary for any property you want. 
%       It contains all the objects seen on the screen
%       and also all the data calculated.
%       It is the antipole of encapsulation basically - imperative.
%   


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Global
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% -- Program Entry Point - Initiate GUI itself
function varargout = FSmodelling(varargin)
% Main function: initiates the GUI for FSmodelling.
% You should NOT have to edit this function ever.
% You do not even really need to understand it beyond the point where
% it calls FSmodelling_OpeningFcn *before* showing the figure and the 
% code passes through here for every callback as well.
% Last Modified by GUIDE v2.5 29-Jul-2019 00:33:49

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FSmodelling_OpeningFcn, ...
                   'gui_OutputFcn',  @(varargin)true, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

% This is where the work is executed
if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% And settings are saved afterwards.
% If something was instant, it likely involved settings and is even more
% important to save, so there is no reason to time this and save only if
% say 10 seconds have passed.
if length(varargin) == 4
    handles = varargin{end};
    handles.settings.write();
end
end  %FSmodelling


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Program start
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Initiate GUI data - handles, previous session
function FSmodelling_OpeningFcn(hObject, ~, handles, varargin)
% Load modules, initiate default values and remove the EzyFit menu
% varargin is ignored.

[thisDir, ~, ~] = fileparts(mfilename('fullpath'));
addpath(thisDir)
binDir = strcat(thisDir, '\bin\');
AddModulesRecursively(binDir)

% Settings are necessary for symmetryInitiate, hence the 
% extra guidata() call here. Otherwise the property does not propagate.
handles.settings = MySettings('global_settings');
handles.author = 'Roemer Hinlopen';
handles.VersionText.String = 'v1.4 | 29 July 2019';
handles.Timer = tic;
guidata(hObject, handles);

GetFolderLocation(handles.settings, handles);
SymmetryInitiate(handles, handles.settings);
handles.output = hObject;
set(hObject, 'MenuBar', 'none');
set(hObject, 'Toolbar', 'none');

% Default size on the screen in relative units:
hObject.Units = 'normalized';
hObject.Position = [0.1 0.1 0.8 0.7];
guidata(hObject, handles);
end %FSmodelling_OpeningFcn


function AddModulesRecursively(dirpath)
% Makes sure other aspects of the code can be located in subdirectories
%
% Add this folder, then add all subfolders to PATH. Recursively.
% Used to make sure all codefiles of the package are in view.
%
% NB: /private subdirectories are special
% They do not have to be added, will raise an error if they are added
% and are automatically visible from their direct parent directories but
% not from anywhere else. It's just that: private.
% e.g. bin/settings/private is always visible from bin/settings but
% will raise an error if attempted to be accessed or made available from
% anywhere else, like bin/api.

addpath(dirpath);
options = dir(dirpath);
for ind=1:length(options)
    name = options(ind).name;
    if strcmp(name, '.') || strcmp(name, '..') || strcmp(name, 'private')
        continue;
    end
    newpath = strcat(dirpath, '\', name);
    if exist(newpath, 'dir')
        AddModulesRecursively(newpath);
    end
end %for
end %AddModulesRecursively


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% API triggers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% High level
%   <changes multiple other API elements>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function SymmetryMenu_Callback(hObject, ~, handles)
% hObject    handle to SymmetryMenu
% eventdata  not used
% handles    structure with handles and user data
%
% Change the symmetry, this has profound effects as each symmetry has
% its own memory, not only for the direct parameters (lattice constants)
% but also through its own set of bands and corrugation factors.

contents = cellstr(get(hObject, 'String'));
symmetry = contents{get(hObject, 'Value')};
s = handles.settings;
s.write();
SwitchSymmetry(handles, s, symmetry);
end


function BandMenu_Callback(hObject, ~, handles)
% Changing the band means reloading a whole bunch of parameters,
% the k coefficients but also mass etc.

contents = cellstr(get(hObject, 'String'));
bandID = contents{get(hObject, 'Value')};
s = handles.settings;
SwitchBand(handles, s, bandID);
end 


function DeleteBandButton_Callback(~, ~, handles)
% Delete from settings as well as the GUI,
% Also switch to 'Select Band'
s = handles.settings;
RemoveBand(handles, s);
end 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Low level: Symmetry Box
%   <changes a single model parameter>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function FolderNameValue_Callback(~, ~, handles)
% Select a new output folder under data/
s = handles.settings;
SetFolderLocation(s, handles.FolderNameValue.String);
end 


function Lattice1Edit_Callback(hObject, ~, handles)
SetSymmPropertyValue(hObject, handles, 'Lattice1');
end


function Lattice2Edit_Callback(hObject, ~, handles)
SetSymmPropertyValue(hObject, handles, 'Lattice2');
end


function Lattice3Edit_Callback(hObject, ~, handles)
SetSymmPropertyValue(hObject, handles, 'Lattice3');
end


function BEdit_Callback(hObject, ~, handles)
SetSymmPropertyValue(hObject, handles, 'B');
end


function BAzumithalEdit_Callback(hObject, ~, handles)
SetSymmPropertyValue(hObject, handles, 'BAzumithal');
end


function BPolarEdit_Callback(hObject, ~, handles)
SetSymmPropertyValue(hObject, handles, 'BPolar');
end


function PrecisionEdit_Callback(hObject, ~, handles)
SetSymmPropertyValue(hObject, handles, 'Precision');
end


function AtomsPerCellEdit_Callback(hObject, ~, handles)
SetSymmPropertyValue(hObject, handles, 'AtomsPerCell')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Low level: Band Box
%   <changes a single model parameter>
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function CoeffEdit01_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 1)
end 


function CoeffEdit02_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 2)
end 


function CoeffEdit03_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 3)
end 


function CoeffEdit04_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 4)
end


function CoeffEdit05_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 5)
end


function CoeffEdit06_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 6)
end 


function CoeffEdit07_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 7)
end


function CoeffEdit08_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 8)
end 


function CoeffEdit09_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 9)
end 


function CoeffEdit10_Callback(hObject, ~, handles)
SetCoefficientValue(hObject, handles, 10)
end


function TauEdit_Callback(hObject, ~, handles)
SetBandPropertyValue(hObject, handles, 'Tau');
end

function KxOffsetEdit_Callback(hObject, ~, handles)
SetBandPropertyValue(hObject, handles, 'KxOffset');
end


function KyOffsetEdit_Callback(hObject, ~, handles)
SetBandPropertyValue(hObject, handles, 'KyOffset');
end


function KzOffsetEdit_Callback(hObject, ~, handles)
SetBandPropertyValue(hObject, handles, 'KzOffset');
end


function EffMassEdit_Callback(hObject, ~, handles)
SetBandPropertyValue(hObject, handles, 'EffMass');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Physics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function FermiSurfaceCallback(~, ~, handles)
% Create a Fermi surface view with color determined by el/hole type.
s = handles.settings;
FermiSurfaceLauncher(handles, s, 0);
end 


function FermiVelocityCallback(~, ~, handles)
% Create a Fermi surface view with colormap |v_fermi|
s = handles.settings;
FermiSurfaceLauncher(handles, s, 1);
end 


function FractionalFilling_Callback(~, ~, handles)
% Calculate what fraction of this band is filled,
% a fully filled band has density 1/unitcell volume
% usually 1/abc (tetra) or 2/abc (triangular)
s = handles.settings;
FractionalFillingLauncher(handles, s);
end


function OrbitPlotButton_Callback(~, ~, handles)
% Find for this one B direction the extremal orbits
% and plot them over the Fermi surface
s = handles.settings;
OrbitPlotLauncher(handles, s);
end 


function OrbitalDistribution_Callback(~, ~, handles)
% Along the B direction, make a distribution of evaluations of the
% frequency and show it.
s = handles.settings;
OrbitalDistributionLauncher(handles, s);
end


function AngleButton_Callback(~, ~, handles)
% Vary theta at the given psi and for each determine the extremal 
% orbits and their frequencies, curvature factors.
s = handles.settings;
AngleDependenceLauncher(handles, s);
end


function LSurfaceButton_Callback(~, ~, handles)
s = handles.settings;
LSurfaceLauncher(handles, s);
end % LSurfaceButton_Callback


function SigmaButton_Callback(~, ~, handles)
s = handles.settings;
SigmaLauncher(handles, s);
end


function Gamma_Callback(~, ~, handles)
s = handles.settings;
HeatCapacityLauncher(handles, s);
end

function LoadButton_Callback(~, ~, handles)
% Replace the settingsfile with another selected by the user.
[file, dirpath] = uigetfile('*.txt');

% cancel is hit.
if isequal(file, 0)
    return;
end

filepath = fullfile(dirpath, file);
s = handles.settings;
SafelyReplaceSettings(s, filepath);
SymmetryMenu_Callback(handles.SymmetryMenu, 0, handles);
end %LoadButton_Callback


function SaveButton_Callback(~, ~, handles)
% Copy the settingsfile to a user specified path.

filepath = SelectSettingsSavePath();
if isequal(filepath, 0)
    return;
end
copyfile(handles.settings.filepath, filepath);
msgbox(sprintf('Succesful save to %s.', filepath));

end %SaveButton_Callback


function ResetButton_Callback(~, ~, handles)
% Delete all settings, reopen the program.

answer = questdlg(...
    'Are you sure you want to delete ALL settings and re-launch?', ...
    'Confirmation', 'Yes', 'Cancel', 'Cancel');

% e.g. Cancel but also window close (= empty string)
if ~strcmp(answer, 'Yes')
    return;
end
handles.settings.destroyAfter = true;
close(handles.figure1);
delete(handles.settings);
FSmodelling();

end %ResetButton_Callback


function CloseFigs_Callback(~, ~, ~)
% Does what it says. Only finds those which are created by the GUI though.
% Also does not affect the GUI itself (though it is a figure), just its
% children / the spawned figures by the functions used in this code.
close all;
end %CloseFigs_Callback


function CloseRequestFcn(hObject, ~, ~)
% Settings will be saved automatically when they go out of scope
% so no need to extra save here. 
delete(hObject);
end %CloseRequestFcn
