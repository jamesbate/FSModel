function ADFigureProperties()
% Set all the labels, fontsizes, etc. for a (theta, F cos(theta)) plot
 
set(get(gca,'XAxis'),'FontSize', FontSize);
set(get(gca,'YAxis'),'FontSize', FontSize);
xlabel('\theta (deg)', 'Fontsize', FontSize);
ylabel('F cos\theta (kT)', 'FontSize', FontSize);
lighting gouraud; 
material shiny;
grid off;

end
