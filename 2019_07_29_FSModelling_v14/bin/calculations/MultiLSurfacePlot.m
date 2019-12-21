function MultiLSurfacePlot(bands)
% Create the LSurface for each band.

figure;
bands = InitiateBands(bands);
for ind = 1:length(bands)
    [cg, vf] = GeometryFromBand(bands{ind});
    LSurfacePlot(cg, vf, bands{ind});
end %for
end %MultiLSurfacePlot
