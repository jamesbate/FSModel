function [x2, y2] = MarchingInterpolate(zz, z0, x, y, dx, dy, stepnr)
% Take the 4 corner values (zz) and interpolate the two sides
% where it crosses z0 to find as close an approximation possible
% for the next point. This happens twice exactly or an error is raised.
%
% zz is a 4-array with northwest, northeast, southeast, southwest
% points surrounding (x, y) shifted with dx/2 and dy/2.
% Stepnr is only used for error messages and an integer.
%
% Responsibility: 4 sides interpolation and assuring no weird paths.

isHigher = zz > z0;
found = 0;
x2 = zeros(1, 2);
y2 = zeros(1, 2);

% Go to the north border
% Interpolate linearly from the northwest corner towards northeast.
if isHigher(1) ~= isHigher(2)
    found = found + 1;
    x2(found) = InterpolateLinearly(x-dx/2, x+dx/2, zz(1), zz(2), z0);
    y2(found) = y + dy/2;  
end

% Go to the east border
% Interpolate linearly from the northeast corner towards southeast.
if isHigher(2) ~= isHigher(3)
    found = found + 1;
    y2(found) = InterpolateLinearly(y+dy/2, y-dy/2, zz(2), zz(3), z0);
    x2(found) = x + dx/2;
end

% Go to the south border
% Interpolate linearly from the southeast corner towards southwest.
if isHigher(3) ~= isHigher(4)
    found = found + 1;
    x2(found) = InterpolateLinearly(x+dx/2, x-dx/2, zz(3), zz(4), z0);
    y2(found) = y - dy/2;
end

% Go to the west border
% Interpolate linearly from the southwest corner towards northwest.
if isHigher(4) ~= isHigher(1)
    found = found + 1;
    y2(found) = InterpolateLinearly(y-dy/2, y+dy/2, zz(4), zz(1), z0);
    x2(found) = x - dx/2;
end

% Exactly 2 futures means success
if found == 2
    return;
end

% Error otherwise
if stepnr < 5
    error('Marching:Starting', ...
          'Stranded after %d steps in (%.3e, %.3e).', stepnr, x, y);
elseif found == 1
    error('Marching:Strand', 'Stranded in an end point (%.3e, %.3e) after %d steps.', ...
          x, y, ind - 1);
elseif found == 0   
    if all(zz >= z0)
        error('Marching:Mini', 'Minimum at (%.3e, %.3e) after %d steps', x, y, stepnr);
    elseif all(zz <= z0)
        error('Marching:Maxi', 'Maximum at (%.3e, %.3e) after %d steps', x, y, stepnr);
    else
        error('Marching:Devi', 'Deviated from the trajectory after %d steps', stepnr);
    end
else
    error('Marching:Saddle', 'Saddle point or curve splitting at (%.3e, %.3e) after %d steps', x, y, stepnr);
end
end %MarchingInterpolation
