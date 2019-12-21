function isMinis = ExtremizeClassifyAll(values)
% Go through the array and mark maxima, minima, jumps, edges, useless.
% These are marked 0, 1, 2, 3, NaN in isMinis respectively.
% There are always 2 3's (this expects sufficient a/b values)

maxi = max(values);
isMinis = zeros(1, length(values));
for ind = 2:length(values) - 1
    prev = values(ind - 1);
    now = values(ind);
    next = values(ind+1);
    
    % If NaN is returned, it is not an extremum
    % If 0/1 is returned it is a max/min
    % If 2 is returned this is at a discontinuity.
    isMinis(ind) = ExtremizeClassifyPoint(prev, now, next, maxi);
end %for

% Overwrite the boundary specially
if ExtremizeClassifyPoint(values(2),values(1),values(2), maxi) == 2
    isMinis(1) = 2;
else
    isMinis(1) = 3;
end
if ExtremizeClassifyPoint(values(end-1),values(end),values(end-1), maxi) == 2
    isMinis(end) = 2;
else
    isMinis(end) = 3;
end
end %ExtremizeClassifyAll
