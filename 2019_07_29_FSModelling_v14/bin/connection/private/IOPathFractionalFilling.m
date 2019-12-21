function location = IOPathFractionalFilling(settings, handles)
% Make the path where the message has to be saved.
% Responsibility: Low level path manipulation

% ends in a char, no \
% The double escape is necessary to escape-the-escape
%
% Responsibility: low level path manipulation
direc = GetFolderLocation(settings, handles);
location = sprintf('%s\\NumberElectrons.txt', direc);
end %IOPathFractionalFilling
