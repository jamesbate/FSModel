function [fFreq,fCover] = MultiOrbitalDistribution(bands)
% Make a figure where the frequency evolution is shown as one walks along
% the magnetic field direction.
% Make a second figure where the coverage of the band is shown.
% Current figure will be fCover by the end.
% Returns the handles of both figures.

colors = winter(length(bands));

fFreq=figure;
fFreq.Units = 'normalized';
fFreq.Position = [0.2 0.3 0.5 0.5];

fCover=figure;
fCover.Units = 'normalized';
fCover.Position = [0.3 0.2 0.5 0.5];
view([1,1,1]);

legendTxts = cell(1, length(bands));
for ind = 1:length(bands)
   geo = GeometryFromBand(bands{ind});
   [aa, bb] = geo.Cover(NrDistributionOrbits);
   
   figure(fCover);
   hold on;
   FermiSurfacePlot(bands{ind},0, 1 - colors(ind,:));
   hold on;
   [planes, freqs] = MakeOrbitalDistribution(geo, bands{ind}, aa, bb, colors(ind,:));
   
   figure(fFreq);
   hold on;
   scatter(planes, freqs / 1000, 10, colors(ind,:), 'filled');
   legendTxts{ind} = bands{ind}('id');
end

figure(fCover);
FSFigureProperties();

figure(fFreq);
legend(legendTxts);
ODFigureProperties();

end



function [planes, freqs] = MakeOrbitalDistribution(geo, band, aa, bb, color)
% Create the orbits that combined should cover the surface and plot them

areas = zeros(1, length(aa));
for ind = 1:length(aa)
    try
        path = geo.CalcPath(aa(ind),bb(ind));
        areas(ind) = ComputeArea(path(:,1),path(:,2),path(:,3));
    catch exc
        if strcmp(exc.identifier, 'Marching:Starting')
            areas(ind) = 0;
        else
            areas(ind) = NaN;
        end
       continue;
    end
   
    filter = ceil(length(path)/50);
    [x,y,z] = FSTransformCoordinates(band,...
                                    path(1:filter:end,1),...
                                    path(1:filter:end,2),...
                                    path(1:filter:end,3));
    x(end+1) = x(1);
    y(end+1) = y(1);
    z(end+1) = z(1);
    z = mod(z+1,2)-1;
    scatter3(x,y,z,3,color, 'filled');
    hold on;
end
hold off;

planes = geo.CalcDistance(aa, bb);
freqs = AreaToFrequency(areas);
end %MakeOrbitalDistribution