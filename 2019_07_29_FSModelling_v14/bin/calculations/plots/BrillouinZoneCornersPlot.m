function BrillouinZoneCornersPlot(oneBand)
% Take this band, extract a/b/c/symmetry and plot the corners of the BZ.
a = oneBand('a');
b = oneBand('b');
c = oneBand('c');
symm = oneBand('symmetry');
hc = GetBrillouinCorners(symm, a, b, c);
scatter3(hc(1:3:end) * a / pi, hc(2:3:end) * a / pi, hc(3:3:end) * c / pi);
end %AddBrillouinCorners
