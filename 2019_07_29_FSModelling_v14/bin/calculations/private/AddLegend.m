function AddLegend(names, colors)
% Make a legend for a 3d plot, forcefully separate from the actual plot
% Both inputs are cell arrays, colors may be longer.
%
% Trick to make a legend unrelated to the graph
% It is possible to make multiple electrons or none at all,
% but in either case the legend should show the electron and hole
% entries as a guide - at least that is how I want it.

xl = xlim; yl = ylim; zl = zlim;
x = 0.5 * (xl(1) + xl(2));
y = 0.5 * (yl(1) + yl(2));
z = 0.5 * (zl(1) + zl(2));
figures = zeros(length(names), 1);

for ind = 1:length(names)
    hold on;
    figures(ind) = plot3(x,y,z,'-','Color',colors{ind},'LineWidth',3);
end %for

leg = legend(figures,names{:});
leg.FontSize = FontSize() / 1.6180339887;
end %AddLegend

