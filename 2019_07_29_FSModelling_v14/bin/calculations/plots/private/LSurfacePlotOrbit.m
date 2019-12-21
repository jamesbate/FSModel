function LSurfacePlotOrbit(xx, yy, zz, color)

% Add the starting point to make it a closed line
% It is a detail, but it really is noticeable.
% Because these figures are beautiful it is annoying to find this ;P
xx(end+1) = xx(1);
yy(end+1) = yy(1);
zz(end+1) = zz(1);
hold on;
plot3(xx, yy, zz, 'Color', color);

end %LSurfacePlotOrbit
