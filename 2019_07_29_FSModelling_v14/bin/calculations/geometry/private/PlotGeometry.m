function PlotGeometry(geometry, color)
% Plots this geometry on the *CURRENT* figure.
%
% Responsibility: Low level implementation of the view. 
% (i.e. you can freely change this to change the view!)

aa = (0:2*pi/100:2*pi);
bb = (0:2*pi/100:2*pi);
[A, B] = meshgrid(aa, bb);
[X, Y, Z] = geometry.Points(A, B);


hold on;
surf(X, Y, Z, ...
     'Facecolor', color, ...
     'EdgeColor', 'none', ...
     'SpecularStrength', 1, ...
     'FaceAlpha', 0.3);

end %PlotGeometry
