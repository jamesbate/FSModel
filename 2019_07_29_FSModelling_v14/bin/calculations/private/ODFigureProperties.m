function ODFigureProperties()
% Set the labels etc.

set(get(gca,'XAxis'),'FontSize', FontSize);
set(get(gca,'YAxis'),'FontSize', FontSize);
xlabel('Distance along field', 'Fontsize', FontSize);
ylabel('Frequency (kT)', 'FontSize', FontSize);
end
