function ReadSettingsFile(stream, forward)
% Read in line by line and send them away as forward(key, value)
% Separates on the first | in each line, skips empty lines, no validation

line = fgetl(stream);
while ischar(line)
   indices = strfind(line, '|');

   if isempty(indices)
       if length(line) > 2
           fprintf('Line in settingsfile corrupt. %s', line);
       end
       continue;
   end

   key = strtrim(line(1:indices(1) - 1));
   value = strtrim(line(indices(1) + 1:end));
   forward(key, value);
   line = fgetl(stream);
end %while
end
