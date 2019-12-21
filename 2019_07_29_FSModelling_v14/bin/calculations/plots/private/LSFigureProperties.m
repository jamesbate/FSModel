function LSFigureProperties()
% Sets all the labels etc for the LSurface plot.

set(get(gca,'XAxis'), 'FontSize', FontSize);
set(get(gca,'YAxis'), 'FontSize', FontSize);
set(get(gca,'ZAxis'), 'FontSize', FontSize);
xlabel('vx * tau (nm)', 'Fontsize', FontSize);
ylabel('vy * tau (nm)', 'FontSize', FontSize);
zlabel('vz * tau (nm)', 'FontSize', FontSize);
lighting gouraud; 
material shiny;
light('Position',[1 0 1],'Style','infinite');
light('Position',[-1 0 1],'Style','infinite');
set(gca,'DataAspectRatio',[1 1 3]);
grid off;

c = colorbar;
c.Label.String = 'Position of orbit in unit cell';
c.Label.FontSize = FontSize;
c.FontSize = FontSize;

end %LSFigureProperties
