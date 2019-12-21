function AddAllModules()
% Move to bin and add all non-private subdirectories to Path.
% Also adds FSModelling main folder to path.

[thisDir, ~, ~] = fileparts(mfilename('fullpath'));
addpath(thisDir)
addpath(strcat(thisDir, '\..'));
binDir = strcat(thisDir, '\..\bin\');
AddModulesRecursively(binDir);
end %AddAllModules

function AddModulesRecursively(dirpath)
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

