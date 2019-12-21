function CoveragePlotOrbits(geometry, aa, bb)
% given a bunch of starting points, make a view of them with rainbow
% colors to show you how far along the index line we are.
%
% Responsibility: Low level plotting. You can adjust this representation!

colors = winter(length(aa));
for ind = 1:length(aa)
    try
        path = geometry.CalcPath(aa(ind),bb(ind));
    catch
        continue;
    end
    hold on;
    
    % This filter is here such that this does not take forever.
    filter = ceil(length(path) / 100);
    scatter3(path(1:filter:end,1),...
             path(1:filter:end,2),...
             path(1:filter:end,3),3,colors(ind,:));
end

end %CoveragePlotOrbits
