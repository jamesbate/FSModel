function xnew = InterpolateLinearly(x1, x2, y1, y2, yres)
% Find the x value where y equals yres using linear interpolation between
% two set points. Guarantees that the result is in the interval or an error
% is raised.

if x1 - x2 == 0
    error('Cannot interpolate sensibly with 2 equal x values');
end
if y1 - y2 == 0
    error('Division by zero when interpolating between equal y values.');
end
  
xnew = x1 + (yres - y1) / (y2 - y1) * (x2 - x1);
  
if (xnew > x1 && xnew > x2) || (xnew < x1 && xnew < x2)
    error('Interpolation is forbidden to leave the interval');
end
end %InterpolateLinearly

