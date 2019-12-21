function arguments = Signature(func)
% Get a list of arguments for a function. 
% e.g. function testfunc(func, a, b, c, haha)
% Call Signature(@testfunc)
%   => ['func', 'a', 'b', 'c', 'haha']

obj = functions(func);
filepath = obj.file;

stream = fopen(filepath, 'r');
if stream == -1
    error('Cannot open file %s', filepath);
end
raii = onCleanup(@()fclose(stream));

% The first function is the one.
line = fgetl(stream);
while true    
    if ~ischar(line)
        error('No function declaration line found in %s', filepath);
    elseif ~isempty(regexp(line, 'function', 'once')) && ...
            ismember('(', line) && ismember(')', line)
        break;
    end
    line = fgetl(stream);
end %while

index1 = strfind(line, '(');
index2 = strfind(line, ')');
argumentString = sprintf(',%s,', line(index1 + 1:index2 - 1));
indices = strfind(argumentString, ',');

arguments = cell(1, length(indices) - 1);
for ind = 1:length(arguments)
   left = indices(ind) + 1;
   right = indices(ind + 1) - 1;
   arguments{ind} = strtrim(argumentString(left:right));
end
end 
