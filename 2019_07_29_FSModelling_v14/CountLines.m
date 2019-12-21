function CountLines()
% Returns the number of lines of code in the entire project.

[direc, ~, ~] = fileparts(mfilename('fullpath'));
display(RecCount(direc, 0));

end %CountLines


function count = RecCount(direc, count)

content = dir(direc);

for ind = 3:length(content)
    path = sprintf('%s\\%s', direc, content(ind).name);    
    if exist(path, 'dir')
        count = RecCount(path, count);
    elseif exist(path, 'file')
        if strcmp(path(end - 1:end), '.m')
            count = count + CountCodeLines(path);
        end
    else
        error('Weird object %s', path);
    end
end %for
end %recCount

function count = CountCodeLines(path)
% Count code lines in the file
% Excludes empty lines, comment lines and 'end' lines.

stream = fopen(path);
if stream == -1
    error('File cannot be opened, %s', path);
end
raii = onCleanup(@()fclose(stream));

count = 0;
line = fgetl(stream);
while ischar(line)
   line = strtrim(line);
   if ~isempty(line) && ~strcmp(line(1), '%')
       if length(line) < 3 || (length(line) > 3 && ~strcmp(line(1:3), 'end'))
           count = count + 1;
       end
   end
   line = fgetl(stream);
end %while
end %CountCodeLines
