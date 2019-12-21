function txtloc = IOPathGamma(settings, handles)
% Make the paths where the heat capacity coefficient has to be stored.
%
% Responsibility: Low level path manipulation

% ends in a char, no \
direc = GetFolderLocation(settings, handles);
txtloc = sprintf('%s\\Gamma.txt', direc);
end %IOPathGamma
