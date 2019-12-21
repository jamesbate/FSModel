function result = Concatenate(varargin)
% Combine a bunch of vectors into a large one.
%
% arrays : cell of arrays
%   >> x = (0:1:2);
%   >> y = (0:1:3);
%   >> z = Concatenate(x, y);
%   >> z = [0, 1, 2, 0, 1, 2, 3];
%
% Or for example
%   >> temp = {x, y};
%   >> z = Concatenate(temp);
%   >> z = [0, 1, 2, 0, 1, 2, 3];
%
% horzcat/vertcat is a mess and situationally you need either or 
% you need to merge a row with column and you end up throwing up.
% This solves the issue by preallocating a large row vector and 
% looping over the vectors.

if length(varargin) == 1
    arrays = varargin{1};
else
    arrays = varargin;
end


len = 0;
for ind =1:length(arrays)
    len = len + numel(arrays{ind});
end

try
    result = zeros(1, len);
    running = 0;
    for ind = 1:length(arrays)
        array = arrays{ind};
        for ind2 = 1:length(array)
            running = running + 1;
            result(running) = array(ind2);
        end %for
    end %for
catch
    result = cell(1, len);
    running = 0;
    for ind = 1:length(arrays)
        array = arrays{ind};
        for ind2 = 1:length(array)
            running = running + 1;
            result(running) = array(ind2);
        end %for
    end %for
end %try

end %Concatenate

