function [figloc, msgloc] = IOPathSigma(settings, handles)
% Make the paths where the sigma tensor is saved.
%
% Responsibility: Low level path manipulation

% ends in a char, no \
direc = GetFolderLocation(settings, handles);
figloc = sprintf('%s\\Sigma.mat', direc);
msgloc = sprintf('%s\\Sigma.txt', direc);
end %IOPathSigma
