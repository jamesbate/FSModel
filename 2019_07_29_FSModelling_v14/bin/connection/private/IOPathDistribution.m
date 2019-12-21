function [freqloc, coverloc] = IOPathDistribution(settings, handles)
% Make the paths where the distribution figures have to be saved.
%
% Responsibility: Low level path manipulation

% ends in a char, no \
direc = GetFolderLocation(settings, handles);
freqloc = sprintf('%s\\OrbitalDistribution.fig', direc);
coverloc = sprintf('%s\\SurfaceCoverage.fig', direc);
end %IOPathOrbits
