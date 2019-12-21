function WriteSettingsFile(stream, keys, values)
% Does the actual formatting and writing to an already opened settingsfile

if length(keys) ~= length(values)
    error('Cannot write when keys %d and values %d do not match', ...
          length(keys), length(values));
end

str = '';
for ind = 1:length(keys)
   % Prevent corruption for this corner case
   if ~isempty(keys{ind})
       str = sprintf('%s%-20s | %s\r\n', str, keys{ind}, values{ind});
   end
end
fprintf(stream, str);
end
