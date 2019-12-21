function FSFigureProperties()
% Set all the labels, fontsizes, etc. for a standard 3d plot in k space.

set(get(gca,'XAxis'),'FontSize', FontSize);
set(get(gca,'YAxis'),'FontSize', FontSize);
set(get(gca,'ZAxis'),'FontSize', FontSize);
xlabel('kx a/\pi', 'Fontsize', FontSize);
ylabel('ky b/\pi', 'FontSize', FontSize);
zlabel('kz c/\pi', 'FontSize', FontSize);
lighting gouraud; 
material shiny;
light('Position',[1 0 1],'Style','infinite');
light('Position',[-1 0 1],'Style','infinite');
set(gca,'DataAspectRatio',[1 1 3]);
grid off;
end %FigureProperties
