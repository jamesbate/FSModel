function [key, value] = MakeValidKeyValue(key, value)
% Reponsible for the semantics and requirements for keys/values

% 1: key type
if ~ischar(key)
   key = char(key);
end

% 2: value type
if isnumeric(value) && isfinite(value) && value == floor(value)
    value = char(sprintf('%d', value));
elseif isnumeric(value)
    if abs(value) > 1e-5 && abs(value) < 1e5
        value = char(sprintf('%.8f', value));
    else
        value = char(sprintf('%.8e', value));
    end
elseif ~ischar(value)
    value = char(value);
end      

% 3: trim
% realize that whitespace is unrecognizable to read in again
% and see part 4
key = strtrim(key);
value = strtrim(value);

% 4: reserved
% | is allowed in values, the first one is the separation and sensitive
% Empty keys are seens as never appropriate, algorithm does not actually
% have a problem with it but 9 out of 10 this is a bug on the user end
% and the remainder it is still bad practise.
if isempty(key)
   error('Setting:Reserved', 'Empty key');
end
if ismember('|', key)
   error('Setting:Reserved', 'Use of | in keys is forbidden');
end

% Newlines will cause corruption in the settings file. 
% Note that this is not a perfect catch all, you can definitely 
% create situations to bypass this and be my guest to corrupt your own 
% files, but this is to prevent the common case.
% Simplest case is to open the file yourself and edit it,
% the path is even given as a property of the settings path.
% Also note that trailing newlines are already removed above
% again showing the intention behind this to be anti corruption 
% in a common case and not strictness / robustness against general cases.
if ismember(char(10), key) || ismember(char(13), key)
   error('Setting:Reserved', 'No newlines in keys.');
end
if ismember(char(10), value) || ismember(char(13), value)
   error('Setting:Reserved', 'No newlines in values.');
end
end %MakeValidKeyValue
