function SaveFigure(path)
% Save the current figure to the given path.
% The extension does not matter, but path does need some kind of extension.
%
% Saves the current figure in 3-fold: as fig, png and pdf.

indices = strfind(path, '.');
noExtension = path(1:indices(end)-1);

figpath = sprintf('%s.fig', noExtension);
pngpath = sprintf('%s.png', noExtension);
pdfpath = sprintf('%s.pdf', noExtension);

saveas(gcf, figpath);
saveas(gcf, pngpath);
print(gcf, pdfpath, '-dpdf', '-opengl', '-bestfit');

end %SaveFigure
